extends Node
 
var hasStarted = false;
var callOutChance = 50;
var numbers = [];
var playerBluffVal;
var enemy_turn = false;
var turn_number = 0;
var life_total = 3;
@onready var anim = $AnimationController;
@export var has_draw_powerup = false;
@export var has_hand_powerup = false;
@export var has_winning_val_powerup = false;


# Chance mechanics
@export var winningVal = 21;
@export var paranoia_value = 3.0;
 
func _ready() -> void:
	print("Enemy_ready ran")
	game_manager.current_turn.connect(_on_turn_changed);
	game_manager.start_game.connect(_on_match_started);
	game_manager.register_enemy();
	print("Enemy Registered")
	print("Draw: ", has_draw_powerup);
	print("Hand: ", has_hand_powerup);
	print("Winning val: ", has_winning_val_powerup);
	if has_draw_powerup:
		game_manager._trigger_draw_powerup();
	if has_hand_powerup:
		game_manager._trigger_hand_powerup();
	if has_winning_val_powerup:
		game_manager._trigger_winning_val_powerup();
 
func _on_turn_changed(turn):
	if turn == game_manager.Turn.ENEMY:
		take_turn();
 
func _on_match_started() -> void:
	life_total = 3;

 
func new_game() -> void:
	life_total = 3;
	newRound();
 
func reset_for_new_round() -> void:
	newRound();
 
# Helper to write to the OpponentActionLabel on the player node
func set_opponent_label(text: String) -> void:
	if game_manager.player != null:
		game_manager.player.get_node("Labels/OpponentActionLabel").text = text
 
func take_turn() -> void:
	if game_manager.player_turn != game_manager.Turn.ENEMY:
		return

	await get_tree().create_timer(randf_range(0.5, 1.0)).timeout

	var should_end = false

	if game_manager.player_state == game_manager.State.DRAW:
		if game_manager.enemy_state == game_manager.State.DRAW:
			anim.set_anim_state(anim.AnimState.SELECT)
			await anim.anim.animation_finished
			anim.set_anim_state(anim.AnimState.IDLE)

			if drawCardDecider():
				set_opponent_label("Opponent: Drew a card")
				drawCard()
				should_end = true
			else:
				set_opponent_label("Opponent: Stayed")
				game_manager.enemy_state = game_manager.State.BLUFF
				should_end = true

		elif game_manager.enemy_state == game_manager.State.BLUFF:
			should_end = true

	elif game_manager.player_state == game_manager.State.BLUFF:
		if game_manager.enemy_state == game_manager.State.DRAW:
			if drawCardDecider():
				set_opponent_label("Opponent: Drew a card")
				drawCard()
			else:
				set_opponent_label("Opponent: Stayed")
				game_manager.enemy_state = game_manager.State.BLUFF
			should_end = true

		elif game_manager.enemy_state == game_manager.State.BLUFF:
			var roundDecision = roundDecider()
			game_manager.enemy_claimed_total = roundDecision["value"]
			game_manager.enemy_total = calculateTotal()
			game_manager.enemy_state = game_manager.State.SHOWDOWN

			audio_manager.play_sfx("i_have_voiceline");
			if roundDecision["bluffing"]:
				set_opponent_label("Opponent claims: " + str(roundDecision["value"]) + " (bluffing!)")
			else:
				set_opponent_label("Opponent reveals: " + str(roundDecision["value"]))
			game_manager.enemy_claimed_total = roundDecision["value"];
			# Adds the claim visual here
			anim.claim_anim(roundDecision["value"]);

			should_end = true

		else:
			should_end = true

	elif game_manager.player_state == game_manager.State.SHOWDOWN:
		if game_manager.enemy_state != game_manager.State.SHOWDOWN:
			var roundDecision = roundDecider()
			game_manager.enemy_claimed_total = roundDecision["value"]
			game_manager.enemy_state = game_manager.State.SHOWDOWN

			audio_manager.play_sfx("i_have_voiceline");
			if roundDecision["bluffing"]:
				set_opponent_label("Opponent claims: " + str(roundDecision["value"]) + " (bluffing!)")
			else:
				set_opponent_label("Opponent reveals: " + str(roundDecision["value"]))
			game_manager.enemy_claimed_total = roundDecision["value"];
			
			anim.claim_anim(roundDecision["value"]);

		game_manager.enemy_total = calculateTotal()

		var enemy_calls = callsBluff(game_manager.player_total, game_manager.claimed_player_total)

		if enemy_calls:
			print("Calling out Bluff")
			anim.set_anim_state(anim.AnimState.CALL_BLUFF)
		else:
			print("Passing")
			anim.set_anim_state(anim.AnimState.PASS)

		await anim.anim.animation_finished
		anim.set_anim_state(anim.AnimState.IDLE)

		await get_tree().create_timer(0.8).timeout

		if enemy_calls:
			set_opponent_label("Opponent: CALLS YOUR BLUFF!")
		else:
			set_opponent_label("Opponent: Accepts your total")

		if !game_manager.player_made_showdown_choice:
			game_manager.end_turn()

		await get_tree().create_timer(0.8).timeout

		if enemy_calls:
			game_manager.enemy_call_bluff()
		else:
			game_manager.enemy_pass_bluff()

		return

	if should_end:
		game_manager.end_turn()

		

	if should_end:
		game_manager.end_turn()
 
func newRound() -> void:
	numbers = [];
	for i in range(2):
		drawCard();
 
func calculateTotal() -> int:
	var totalInHand = 0;
	for number in numbers:
		totalInHand += number;
	game_manager.enemy_total = totalInHand;
	return totalInHand;
 
func generateNumber() -> int:
	return randi_range(1, 9);
 
func roundDecider() -> Dictionary:
	var totalInHand = calculateTotal();
	var distance = winningVal - totalInHand;
	var bluff_chance = distance / float(winningVal);
	if bluff_chance != 0:
		bluff_chance += randf_range(-0.1, 0.1);
		bluff_chance = clamp(bluff_chance, 0.0, 1.0);
	var will_bluff = randf() < bluff_chance;
 
	var shown_value: int
	if will_bluff:
		shown_value = generate_bluff_value(totalInHand);
	else:
		shown_value = totalInHand;
 	
	return {
		"bluffing": will_bluff,
		"value": shown_value
	};
 
func drawCardDecider() -> bool:
	var currentTotal = calculateTotal();
	var card_count = numbers.size();
	var target = winningVal;
 
	if currentTotal >= target || card_count >= 5:
		game_manager.enemy_state = game_manager.State.BLUFF;
		return false;
 
	var distance = target - currentTotal;
	var draw_chance = distance / float(target);
	draw_chance = pow(draw_chance, 1.5);
	draw_chance += randf_range(-0.05, 0.05);
	draw_chance = clamp(draw_chance, 0.0, 1.0);
 
	if randf() < draw_chance:
		game_manager.enemy_state = game_manager.State.DRAW;
		return true;
	else:
		game_manager.enemy_state = game_manager.State.BLUFF;
		return false;
 
func drawCard() -> void:
	numbers.append(generateNumber());
 
func generate_bluff_value(real_value: int) -> int:
	var min_bluff = max(real_value, game_manager.claimed_player_total) + 1;
	if min_bluff > winningVal:
		return real_value;
	var gameRange = winningVal - min_bluff;
	var t = pow(randf(), 2.0);
	var bluff = min_bluff + int(gameRange * t);
	return clamp(bluff, min_bluff, winningVal);
 
func callsBluff(real_val: int, bluff_val: int) -> bool:
	var lie_size = bluff_val - real_val;
	if lie_size <= 0:
		return false;
	var proximity = winningVal - bluff_val;
	var closeness = 1.0 / (proximity + 1.0);
	var suspicion = lie_size * closeness;
	var call_chance = clamp(suspicion / paranoia_value, 0.0, 1.0);
	call_chance += randf_range(-0.2, 0.2);
	call_chance = clamp(call_chance, 0.0, 1.0);
 
	if bluff_val >= 19 && bluff_val <= 23:
		call_chance *= 1.3;
		call_chance = clamp(call_chance, 0.0, 1.0);
 
	return randf_range(0, 1) < call_chance;
