extends Node2D

@onready var main = $"..";

#Life Counter
var player_life = 3
var actual_total = 0
var claimed_total = 0
var game_over = false
var cards = []
var is_player_turn = false;
@onready var bluff_buttons = $BluffUI;
@onready var draw_buttons = $ActionButton;
@onready var showdown_buttons = $ShowdownButtons;
@onready var player_life_label = $PlayerLifeLabel;
@onready var opponent_life_label = $OpponentLifeLabel;
@onready var monitor_cards = $MonitorCards;
signal restart_game;


# starting the game
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	start_match()
	game_manager.register_player(self);
	game_manager.current_turn.connect(_on_turn_changed);
	game_manager.start_game.connect(_on_match_started);

func get_life() -> int:
	return player_life;

func _on_turn_changed(turn) -> void:
	if turn == game_manager.Turn.PLAYER:
		if game_manager.player_state == game_manager.State.DRAW: 
			to_phase_1();
		elif game_manager.player_state == game_manager.State.BLUFF:
			if game_manager.enemy_state == game_manager.State.BLUFF:
				print("IN BLUFF PHASE NOW");
				to_phase_2();
			else:
				to_phase_2();
		else:
			if game_manager.enemy_state == game_manager.State.BLUFF:
				game_manager.end_turn();
			elif game_manager.enemy_state == game_manager.State.SHOWDOWN:
				to_phase_3();
	else:
		to_enemy_turn();

func _on_match_started() -> void:
	start_match();

#Starting the Match
func start_match():
	player_life = 3
	game_manager.update_life_labels()
	start_round()
	
# Restarting the round
func start_round():
	monitor_cards.clear_cards()
	cards = []
	actual_total = 0
	claimed_total = 0
	game_over = false
	
	to_phase_1();
	
	draw_cards();

	game_manager.player_total = calculate_total();
	game_manager.claimed_player_total = calculate_total();
	$ActualTotalLabel.text = "Actual Total: " + str(game_manager.player_total);
	$ClaimedTotalLabel.text = "Claimed Total: -"
	$ResultLabel.text = "Result:"
	$OpponentActionLabel.text = "Opponent:"
	$BluffUI/Control/BluffInput.visible = false
	$BluffUI/Control/BluffInput.text = ""
	$BluffUI/Control/BluffInput.placeholder_text = "Enter Bluff Number"
	
	
# Drawing the card
func _on_draw_card_button_pressed():
	await draw_buttons.get_child(0).anim.animation_finished;
	if cards.size() < 5:
		game_manager.player_state = game_manager.State.DRAW;
		draw_cards();
		actual_total = calculate_total();
		$ActualTotalLabel.text = "Actual Total: " + str(calculate_total());
	else:
		game_manager.player_state = game_manager.State.BLUFF;
	main.screen_shake()
	game_manager.end_turn();
	
func draw_cards() -> void:
	var card;
	if cards.size() < 2:
		print("card size is less than 2");
		for i in range(2):
			card = randi_range(1, 9);
			$MonitorCards.show_card(card)
			cards.append(card);
		print(cards);
	elif cards.size() < 5:
		print("card size is less than 5");
		card = randi_range(1, 9);
		cards.append(card);
		$MonitorCards.show_card(card);
		print(cards);

	

func calculate_total() -> int:
	var total = 0;
	for card in cards:
		total += card;
	game_manager.player_total = total;
	return total;

# To have actual number without bluffing
func _on_stay_button_pressed():
	#if game_over:
		#return
	game_manager.player_total = calculate_total();
	game_manager.claimed_player_total = calculate_total();
	$ActualTotalLabel.text = "Actual Total: " + str(game_manager.player_total);
	$ClaimedTotalLabel.text = "Claimed Total: " + str(game_manager.claimed_player_total);
	game_manager.player_state = game_manager.State.BLUFF;
	print("Player stays. Now entering Bluff Phase...");
	#to_enemy_turn();
	game_manager.end_turn();
	await to_phase_2();
	if game_over:
		return
	main.screen_shake()

func to_phase_1() -> void:
	draw_buttons.visible = true;
	bluff_buttons.visible = false;
	showdown_buttons.visible = false;
	
func to_phase_2() -> void:
	draw_buttons.visible = true;
	draw_buttons.get_child(0)._on_change_to_truth();
	await draw_buttons.get_child(0).anim.animation_finished;
	bluff_buttons.visible = true;
	bluff_buttons.get_child(0).visible = true; # Makes the bluff button appear
	bluff_buttons.get_child(1).visible = true; # Makes the truth button appear
	bluff_buttons.get_child(2).get_child(0).visible = false;
	draw_buttons.visible = false; # Makes the draw and stay buttons disappear
	showdown_buttons.visible = false; # Ensures the showdown buttons are still invisible
	
func to_phase_3() -> void:
	bluff_buttons.visible = false;
	draw_buttons.visible = false;
	showdown_buttons.visible = true;

func to_enemy_turn() -> void:
	draw_buttons.visible = false;
	bluff_buttons.visible = false;

# Bluffing mechanic activates
func _on_bluff_button_pressed():
	if game_over:
		return
	main.screen_shake()

	$OpponentActionLabel.text = "Opponent: Enter bluff number and press Enter"
	bluff_buttons.visible = true;
	bluff_buttons.get_child(0).visible = false;
	bluff_buttons.get_child(1).visible = false;
	var bluff_input = bluff_buttons.get_child(2).get_child(0);
	
	bluff_input.position = Vector2(576, 324);
	bluff_input.visible = true;
	bluff_input.text = "";
	bluff_input.grab_focus();
	print(bluff_buttons.visible);
	print(bluff_buttons.get_child(2).visible);
	print(bluff_buttons.get_child(2).get_child(0).visible);
	
func _on_bluff_input_text_submitted(new_text):
	if game_over:
		return
	main.screen_shake()

	
	if new_text.is_valid_int():
		claimed_total = int(new_text)
		game_manager.claimed_player_total = claimed_total;
		$ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)
		bluff_buttons.get_child(2).get_child(0).visible = false;
		bluff_buttons.get_child(2).get_child(0).text = "";
	
	game_manager.player_state = game_manager.State.SHOWDOWN;
	game_manager.end_turn();
	

func _on_bluff_input_text_changed(new_text: String) -> void:
	var filtered = ""
	
	for c in new_text:
		if c.is_valid_int() or c == "-":
			filtered += c
	
	if filtered != new_text:
		bluff_buttons.get_child(2).get_child(0).text = filtered
		bluff_buttons.get_child(2).get_child(0).caret_column = filtered.length()


func _on_truth_button_pressed() -> void:
	if game_over:
		return;
	
	await bluff_buttons.get_child(1).anim.animation_finished;
	
	claimed_total = calculate_total();
	game_manager.claimed_player_total = claimed_total;
	game_manager.player_total = calculate_total();
	$ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total);
	game_manager.player_state = game_manager.State.SHOWDOWN;
	game_manager.end_turn();

# Restart Game
func _on_restart_button_pressed() -> void:
	emit_signal("restart_game");

func set_buttons_enabled(enabled):
	$ActionButton/DrawCardButton.disabled = not enabled
	$ActionButton/StayButton.disabled = not enabled
	$BluffUI/BluffButton.disabled = not enabled
	$BluffUI/Control/BluffInput.editable = enabled


func _on_call_bluff_button_pressed() -> void:
	print("I call your bluff!");


func _on_pass_button_pressed() -> void:
	print("I'll accept that number");
	game_manager.end_turn();
