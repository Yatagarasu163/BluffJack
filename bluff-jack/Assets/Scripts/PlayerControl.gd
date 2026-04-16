extends Node2D

#Scren Shake Values
@export var shake_strength_min: float = 2.0
@export var shake_strength_max: float = 6.0
@export var shake_count: int = 4
@export var shake_speed: float = 0.03
@export var return_speed: float = 0.05

#Life Counter
var player_life = 3
var opponent_life = 3

var actual_total = 0
var claimed_total = 0
var opponent_total = 0
var game_over = false
var cards = []
var is_player_turn = false;
@onready var bluff_buttons = $BluffUI;
@onready var draw_buttons = $ActionButton;
@onready var player_life_label = get_node("PlayerLifeLabel");

# starting the game
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	start_match()

#Starting the Match
func  start_match():
	player_life = 3
	opponent_life = 3
	update_life_labels()
	start_round()
	
# Restarting the round
func start_round():
	cards = []
	actual_total = 0
	claimed_total = 0
	opponent_total = randi_range(15, 25)
	game_over = false
	draw_cards();
	
	to_phase_1();
	
	$MonitorCards.clear_cards()

	$ActualTotalLabel.text = "Actual Total: 0"
	$ClaimedTotalLabel.text = "Claimed Total: -"
	$ResultLabel.text = "Result:"
	$OpponentActionLabel.text = "Opponent:"
	$BluffUI/Control/BluffInput.visible = false
	$BluffUI/Control/BluffInput.text = ""
	$BluffUI/Control/BluffInput.placeholder_text = "Enter Bluff Number"
	
	
# Drawing the card
func _on_draw_card_button_pressed():
	draw_cards();
	actual_total = calculate_total();
	
	screen_shake()
	
	$ActualTotalLabel.text = "Actual Total: " + str(calculate_total());
	
func draw_cards() -> void:
	if game_over:
		return;
	
	if cards.size() < 2:
		for i in range(2):
			var card = randi_range(1, 9);
			cards.append(card);
		print(cards);
		return;
	
	if cards.size() < 5:
		var card = randi_range(1, 9);
		cards.append(card);
		print(cards);
		return
		
	var card = randi_range(1, 9)
	cards.append(card)
	$MonitorCards.show_card(card)
	

func calculate_total() -> int:
	var total = 0;
	for card in cards:
		total += card;
	return total;
	$ActualTotalLabel.text = "Actual Total: " + str(actual_total)

# To have actual number without bluffing
func _on_stay_button_pressed():
	to_phase_2();
	if game_over:
		return
	screen_shake()

	claimed_total = actual_total
	$ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)
	resolve_opponent_decision()
	
func to_phase_2() -> void:
	bluff_buttons.visible = true;
	bluff_buttons.get_child(1).get_child(0).text = "";
	draw_buttons.visible = false;

func to_phase_1() -> void:
	draw_buttons.visible = true;
	bluff_buttons.visible = false;

# Bluffing mechanic activates
func _on_bluff_button_pressed():
	if game_over:
		return
	screen_shake()

	$OpponentActionLabel.text = "Opponent: Enter bluff number and press Enter"
	
	$BluffUI/Control/BluffInput.visible = true
	$BluffUI/Control/BluffInput.text = ""
	$BluffUI/Control/BluffInput.grab_focus()
	
func _on_bluff_input_text_submitted(new_text):
	if game_over:
		return
	screen_shake()

	if new_text.is_valid_int():
		claimed_total = int(new_text)
		$ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)
		$BluffUI/Control/BluffInput.visible = false
		$BluffUI/Control/BluffInput.text = ""
		resolve_opponent_decision()

# Opponents decision
func resolve_opponent_decision():
	var calls_bluff = randi() % 2 == 0

	if calls_bluff:
		$OpponentActionLabel.text = "Opponent called bluff!"

		if claimed_total != actual_total:
			player_loses_round("Result: You Lose! Bluff caught.")
		else:
			opponent_loses_round("Result: You Win! Opponent called bluff wrongly.")
	else:
		$OpponentActionLabel.text = "Opponent accepted your claim."
		resolve_normal_result()

# Normal Result without bluffing 
func resolve_normal_result():
	var winner = get_winner(claimed_total, opponent_total)

	if winner == "player":
		opponent_loses_round("Result: You Win! Opponent had " + str(opponent_total))
	elif winner == "opponent":
		player_loses_round("Result: You Lose! Opponent had " + str(opponent_total))
	else:
		$ResultLabel.text = "Result: Draw! Opponent had " + str(opponent_total)
		game_over = true
		to_phase_1();
	

#Winning Logic
func get_winner(player_total, enemy_total):
	if player_total == 21 and enemy_total != 21:
		return "player"
	elif enemy_total == 21 and player_total != 21:
		return "opponent"
	elif player_total == 21 and enemy_total == 21:
		return "draw"

	if player_total <= 21 and enemy_total > 21:
		return "player"
	elif enemy_total <= 21 and player_total > 21:
		return "opponent"

	if player_total <= 21 and enemy_total <= 21:
		if player_total > enemy_total:
			return "player"
		elif enemy_total > player_total:
			return "opponent"
		else:
			return "draw"

	if player_total > 21 and enemy_total > 21:
		var player_diff = player_total - 21
		var enemy_diff = enemy_total - 21

		if player_diff < enemy_diff:
			return "player"
		elif enemy_diff < player_diff:
			return "opponent"
		else:
			return "draw"

	return "draw"

# When Player Loses the round 
func player_loses_round(message):
	player_life -= 1
	update_life_labels()
	$ResultLabel.text = message
	$BluffUI/Control/BluffInput.visible = false
	
	$MonitorCards.clear_cards()
	
	if player_life <= 0:
		$ResultLabel.text = message + " Game Over! You lose the match."
	
	game_over = true
	to_phase_1();
		
# If the opponent loses the round
func opponent_loses_round(message):
	opponent_life -= 1
	update_life_labels()
	$ResultLabel.text = message
	$BluffUI/Control/BluffInput.visible = false
	
	$MonitorCards.clear_cards()
	
	if opponent_life <= 0:
		$ResultLabel.text = message + " You win " 
	
	game_over = true
	to_phase_1();
	
#Updating Life labels
func update_life_labels():
	player_life_label.text = "Player Life: " + str(player_life)
	$OpponentLifeLabel.text ="Opponent Life: " + str(opponent_life)
	
# Restart Game
func _on_restart_button_pressed():
	if player_life <= 0 or opponent_life <= 0:
		start_match()
	else:
		start_round()
	

func set_buttons_enabled(enabled):
	$ActionButton/DrawCardButton.disabled = not enabled
	$ActionButton/StayButton.disabled = not enabled
	$BluffUI/BluffButton.disabled = not enabled
	$BluffUI/Control/BluffInput.editable = enabled

func screen_shake():
	var original_pos = position
	
	var tween = create_tween()
	
	for i in range(shake_count):
		var strength = randf_range(shake_strength_min,shake_strength_max)
		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		
		tween.tween_property(self, "position", original_pos + offset, 0.03)
	#Returning it to the original Position
	tween.tween_property(self, "position", original_pos, 0.05)
