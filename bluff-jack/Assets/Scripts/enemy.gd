extends Node

var hasStarted = false;
var callOutChance = 50;
var numbers = [];
var playerBluffVal;
var enemy_turn = false;
var turn_number = 0;
var life_total = 3;


# Chance mechanics
@export var winningVal = 21;
@export var paranoia_value = 3.0;

func _ready() -> void:
	game_manager.current_turn.connect(_on_turn_changed);
	game_manager.start_game.connect(_on_match_started);
	game_manager.register_enemy();
	pass

func _on_turn_changed(turn):
	if turn == game_manager.Turn.ENEMY:
		take_turn();

func _on_match_started() -> void:
	new_game();

func new_game() -> void:
	life_total = 3;
	newRound();

func take_turn() -> void:
	if game_manager.player_turn != game_manager.Turn.ENEMY:
		return;
	
	await get_tree().create_timer(0.5).timeout;
	
	var should_end = false;
	
	print("Enemy State: ", game_manager.enemy_state);

	if game_manager.player_state == game_manager.State.DRAW:
		if game_manager.enemy_state == game_manager.State.DRAW:
			if drawCardDecider():
				print("Enemy going to draw a card...");
				drawCard();
				print("Current enemy hand: ", numbers);
				should_end = true;
			else:
				game_manager.enemy_state = game_manager.State.BLUFF;
				should_end = true;
		elif game_manager.enemy_state == game_manager.State.BLUFF: 
			print("Enemy already in Bluff Phase");
			should_end = true;
	elif game_manager.player_state == game_manager.State.BLUFF:
		if game_manager.enemy_state == game_manager.State.DRAW:
			if drawCardDecider():
				print("Enemy going to draw a card...");
				drawCard();
				print("Current enemy hand: ", numbers);
			should_end = true;
		elif game_manager.enemy_state == game_manager.State.BLUFF:
			var roundDecision = roundDecider();
			if roundDecision["bluffing"]:
				print("Enemy is bluffing: ", roundDecision["value"]);
				game_manager.enemy_claimed_total = roundDecision["value"];
			else:
				print("Enemy is not bluffing: ", roundDecision["value"]);
				game_manager.enemy_claimed_total = roundDecision["value"];
			game_manager.enemy_state = game_manager.State.SHOWDOWN;
			should_end = true;
		else: 
			should_end = true;
	elif game_manager.player_state == game_manager.State.SHOWDOWN:
		if game_manager.enemy_state == game_manager.State.BLUFF:
			var roundDecision = roundDecider();
			if roundDecision["bluffing"]:
				print("Enemy is bluffing: ", roundDecision["value"]);
				game_manager.enemy_claimed_total = roundDecision["value"];
			else:
				print("Enemy is not bluffing: ", roundDecision["value"]);
				game_manager.enemy_claimed_total = roundDecision["value"];
			game_manager.enemy_state = game_manager.State.SHOWDOWN;
			callsBluff(game_manager.player_total, game_manager.claimed_player_total);;
			should_end = true;
			
		else:
			game_manager.enemy_state = game_manager.State.SHOWDOWN;
			callsBluff(game_manager.player_total, game_manager.claimed_player_total);;
			should_end = true;
	
	if should_end:
		game_manager.end_turn();

# Starts a new hand for the AI
func newRound() -> void:
	numbers = [];
	for i in range(2):
		drawCard();
	print("Current Enemy Starting Hand: ", numbers);

# Testing purposes
func _on_button_pressed() -> void:
	take_turn();


# Calculates the total value of the numbers in the AI's hand.
func calculateTotal() -> int:
	var totalInHand = 0;
	
	for number in numbers:
		totalInHand += number;
	game_manager.enemy_total = totalInHand;
	return totalInHand;

# Generates a pseudo random number for the AI
func generateNumber() -> int: 
	return randi_range(1, 9);

# Decides what the AI will do for its round
func roundDecider() -> Dictionary:
	var totalInHand = calculateTotal();
	var distance = winningVal - totalInHand;
	var bluff_chance = distance / float(winningVal);
	if(bluff_chance != 0):
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
	
# Decides if the AI will draw a card or not
func drawCardDecider() -> bool:
	var currentTotal = calculateTotal();
	var card_count = numbers.size();
	var target = winningVal;
	
	if currentTotal >= target || card_count >= 5:
		game_manager.enemy_state = game_manager.State.BLUFF;
		return false;

	var distance = target - currentTotal
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
		

# Draws a card for the AI.
func drawCard() -> void:
	numbers.append(generateNumber());

# Determines the value that the AI will use to bluff
func generate_bluff_value(real_value: int) -> int:
	var min_bluff = max(real_value, game_manager.claimed_player_total) + 1;
	if min_bluff > winningVal: 
		return real_value;
	var gameRange = winningVal - min_bluff;
	var t = pow(randf(), 2.0);
	var bluff = min_bluff + int(gameRange * t);
	return clamp(bluff, min_bluff, winningVal);

# Determines if the AI will call the player's bluff or not
func callsBluff(real_val: int, bluff_val: int) -> bool:
	var lie_size = bluff_val - real_val;
	if abs(lie_size) <= 0:
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
