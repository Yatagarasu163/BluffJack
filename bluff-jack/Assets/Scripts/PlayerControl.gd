extends Node2D

@onready var main = $"..";

#Life Counter
@export var player_life = 3
var actual_total = 0
var claimed_total = 0
var game_over = false
var cards = []
var is_player_turn = false;
@onready var bluff_buttons = $BluffUI;
@onready var draw_buttons = $ActionButton;
@onready var showdown_buttons = $ShowdownButtons;
@onready var player_life_label = $Labels/PlayerLifeLabel;
@onready var opponent_life_label = $Labels/OpponentLifeLabel;
@onready var monitor_cards = $MonitorCards;
signal restart_game;
@onready var anim = $AnimationController;
var draw_powerup = false;
var current_bluff_value := ""
@onready var bluff_input = $BluffUI/Control/BluffInput
 
 
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	start_match()
	game_manager.register_player(self);
	game_manager.current_turn.connect(_on_turn_changed);
	game_manager.start_game.connect(_on_match_started);
	bluff_input.editable = false
	bluff_input.visible = false
	
func keypad_press(value: String) -> void:
	if current_bluff_value.length() >= 2:
		return
	current_bluff_value += value 
	bluff_input.text = current_bluff_value
 
func get_life() -> int:
	anim._update_life_anim(player_life);
	return player_life;
 
func _on_turn_changed(turn) -> void:
	if turn == game_manager.Turn.PLAYER:
		
		# Triggers the draw powerup from the enemy
		if draw_powerup:
			_draw_powerup();
			draw_powerup = true;
			
		if game_manager.player_state == game_manager.State.DRAW:
			to_phase_1();
		elif game_manager.player_state == game_manager.State.BLUFF:
			if game_manager.enemy_state == game_manager.State.BLUFF:
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
 
func start_match():
	player_life = 3
	game_manager.update_life_labels()
	start_round()
 
func start_round():
	game_manager.reset_round_flags()
	monitor_cards.clear_cards()
	cards = []
	actual_total = 0
	claimed_total = 0
	game_over = false
	
	#to_phase_1();
	
	draw_cards();
	
	game_manager.player_total = calculate_total();
	game_manager.claimed_player_total = calculate_total();
	$Labels/ActualTotalLabel.text = "Actual Total: " + str(game_manager.player_total);
	$Labels/ClaimedTotalLabel.text = "Claimed Total: -"
	$Labels/ResultLabel.text = "Result:"
	# FIX: Clear the OpponentActionLabel at the start of every round
	$Labels/OpponentActionLabel.text = "Opponent:"
	$BluffUI/Control/BluffInput.visible = false
	$BluffUI/Control/BluffInput.text = ""
	$BluffUI/Control/BluffInput.placeholder_text = "Enter Bluff Number"
 
func _on_draw_card_button_pressed():
	await draw_buttons.get_child(0).anim.animation_finished;
	if cards.size() < 5:
		game_manager.player_state = game_manager.State.DRAW;
		draw_cards();
		actual_total = calculate_total();
		$Labels/ActualTotalLabel.text = "Actual Total: " + str(calculate_total());
	else:
		game_manager.player_state = game_manager.State.BLUFF;
	main.screen_shake()
	game_manager.end_turn();
 
func draw_cards() -> void:
	var card;
	if cards.size() < 2:
		for i in range(2):
			card = randi_range(1, 9);
			$MonitorCards.show_card(card)
			cards.append(card);
	elif cards.size() < 5:
		card = randi_range(1, 9);
		cards.append(card);
		$MonitorCards.show_card(card);
 
func calculate_total() -> int:
	var total = 0;
	for card in cards:
		total += card;
	game_manager.player_total = total;
	return total;
 
func _on_stay_button_pressed():
	main.screen_shake()
	#if game_over:
		#return
	game_manager.player_total = calculate_total();
	game_manager.claimed_player_total = calculate_total();
	$Labels/ActualTotalLabel.text = "Actual Total: " + str(game_manager.player_total);
	$Labels/ClaimedTotalLabel.text = "Claimed Total: " + str(game_manager.claimed_player_total);
	game_manager.player_state = game_manager.State.BLUFF;
	game_manager.end_turn();
	await to_phase_2();
	if game_over:
		return

func to_phase_1() -> void:
	print("Phase 1 is being called")
	draw_buttons.visible = false;
	bluff_buttons.visible = false;
	
	showdown_buttons.visible = true;
	showdown_buttons.get_child(0)._on_change_to_truth();
	await showdown_buttons.get_child(0).anim.animation_finished;
	showdown_buttons.get_child(1)._on_change_to_truth();
	await showdown_buttons.get_child(1).anim.animation_finished;
	showdown_buttons.visible = false;
	
	draw_buttons.visible = true;

 
func to_phase_2() -> void:
	print("Phase 2 is being called")
	draw_buttons.visible = true;
	draw_buttons.get_child(0)._on_change_to_truth();
	await draw_buttons.get_child(0).anim.animation_finished;
	draw_buttons.get_child(1)._on_change_to_truth();
	await draw_buttons.get_child(1).anim.animation_finished;
	draw_buttons.visible = false;
	bluff_buttons.visible = true;
	bluff_buttons.get_child(0).visible = true;
	bluff_buttons.get_child(1).visible = true;
	bluff_buttons.get_child(2).get_child(0).visible = false;
	draw_buttons.visible = false;
	showdown_buttons.visible = false;
 
func to_phase_3() -> void:
	print("Phase 3 is being called")
	bluff_buttons.visible = true;
	bluff_buttons.get_child(0)._on_change_to_truth();
	await bluff_buttons.get_child(0).anim.animation_finished;
	bluff_buttons.get_child(1)._on_change_to_truth();
	await bluff_buttons.get_child(1).anim.animation_finished;
	bluff_buttons.visible = false;
	draw_buttons.visible = false;
	showdown_buttons.get_child(0)._on_idle();
	showdown_buttons.get_child(1)._on_idle();
	showdown_buttons.visible = true;
	
 
func to_enemy_turn() -> void:
	draw_buttons.visible = false;
	bluff_buttons.visible = false;
 
func _on_bluff_button_pressed():
	print("Bluff button pressed")
	if game_over:
		return
	main.screen_shake()
	await bluff_buttons.get_child(0).anim.animation_finished;

	$Labels/OpponentActionLabel.text = "Opponent: Enter bluff number and press Enter"
	bluff_buttons.visible = true;
	bluff_buttons.get_child(0).visible = false;
	bluff_buttons.get_child(1).visible = false;
	
	current_bluff_value = ""
	bluff_input.position = Vector2(576, 324)
	bluff_input.visible = true
	bluff_input.text = ""
	
	bluff_input.grab_focus();
 
func _on_bluff_input_text_submitted(new_text):
	if game_over:
		return
	main.screen_shake()

	
	if new_text.is_valid_int():
		claimed_total = int(new_text)
		game_manager.claimed_player_total = claimed_total;
		$Labels/ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)
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
	main.screen_shake();
	
	await bluff_buttons.get_child(1).anim.animation_finished;
	
	claimed_total = calculate_total();
	game_manager.claimed_player_total = claimed_total;
	game_manager.player_total = calculate_total();
	$Labels/ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total);
	game_manager.player_state = game_manager.State.SHOWDOWN;
	game_manager.end_turn();
 
func _on_restart_button_pressed() -> void:
	emit_signal("restart_game");
 
func set_buttons_enabled(enabled):
	$ActionButton/DrawCardButton.disabled = not enabled
	$ActionButton/StayButton.disabled = not enabled
	$BluffUI/BluffButton.disabled = not enabled
	$BluffUI/Control/BluffInput.editable = enabled
 
func _on_call_bluff_button_pressed() -> void:
	if game_over:
		return
	main.screen_shake();
	game_manager.player_call_bluff()
 
func _on_pass_button_pressed() -> void:
	if game_over:
		return
	main.screen_shake();
	game_manager.player_pass_bluff()
 

	print("I'll accept that number");
	
func _replay_button_pressed():
	print("Replay pressed")
	get_tree().reload_current_scene()
	
func _next_level_button_pressed():
	print("Next Level Pressed")
	get_tree().change_scene_to_file("res://Scenes/Level 3.tscn")


func _on_replay_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_next_level_button_pressed() -> void:
	var current_scene = get_tree().current_scene.scene_file_path
	var file_name = current_scene.get_file()
	var level_number = file_name.get_basename().trim_prefix("Level")
	
	var next_level_number = int(level_number) + 1
	var next_scene_path = "res://Scenes/Level" + str(next_level_number) + ".tscn"
	
	if ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("No more levels!")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Prefabs/Main_Menu.tscn")
	

func _draw_powerup() -> void:
	print("Before powerup: ", cards);
	var changed_card_position:int = randi_range(0, 1);
	var new_value:int = randi_range(1, 9);
	cards[changed_card_position] = new_value;
	print("After powerup: ", cards);
	
	# Find a way to update the visuals here. @Saif Musthafa, the rastafarah IShowSpeed 
	
