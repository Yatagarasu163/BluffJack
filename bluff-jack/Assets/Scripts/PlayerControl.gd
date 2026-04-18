extends Node2D

@onready var main = $".."

# Life Counter
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
var hand_powerup = false;
var current_bluff_value := ""
var tens_digit := 0
var ones_digit := 0

# Keypad panel references
@onready var bluff_input_panel = $BluffInputPanel
@onready var bluff_display = $BluffInputPanel


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	start_match()

	game_manager.register_player(self)
	game_manager.current_turn.connect(_on_turn_changed)
	game_manager.start_game.connect(_on_match_started)

	bluff_input_panel.visible = false


func get_life() -> int:
	anim._update_life_anim(player_life)
	return player_life


func _on_turn_changed(turn) -> void:
	if turn == game_manager.Turn.PLAYER:
		if draw_powerup:
			print("DRAW POWERUP TRIGGERING");
			_draw_powerup();
			draw_powerup = false;
		if hand_powerup:
			print("HAND POWERUP TRIGGERING")
			_hand_powerup();
			hand_powerup = false;
			
		if game_manager.player_state == game_manager.State.DRAW:
			to_phase_1()
		elif game_manager.player_state == game_manager.State.BLUFF:
			if game_manager.enemy_state == game_manager.State.BLUFF:
				to_phase_2()
			else:
				to_phase_2()
		else:
			if game_manager.enemy_state == game_manager.State.BLUFF:
				game_manager.end_turn()
			elif game_manager.enemy_state == game_manager.State.SHOWDOWN:
				to_phase_3()
	else:
		to_enemy_turn()


func _on_match_started() -> void:
	start_match()


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

	tens_digit = 0
	ones_digit = 0

	bluff_input_panel.visible = false
	#bluff_display.show_number(0, 0)

	draw_cards()

	game_manager.player_total = calculate_total()
	game_manager.claimed_player_total = calculate_total()

	$Labels/ActualTotalLabel.text = "Actual Total: " + str(game_manager.player_total)
	$Labels/ClaimedTotalLabel.text = "Claimed Total: -"
	$Labels/ResultLabel.text = "Result:"
	$Labels/OpponentActionLabel.text = "Opponent:"


func _on_draw_card_button_pressed():
	audio_manager.play_sfx("button_press");
	await draw_buttons.get_child(0).anim.animation_finished

	if cards.size() < 5:
		game_manager.player_state = game_manager.State.DRAW
		draw_cards()
		actual_total = calculate_total()
		$Labels/ActualTotalLabel.text = "Actual Total: " + str(calculate_total())
	else:
		game_manager.player_state = game_manager.State.BLUFF

	main.screen_shake()
	game_manager.end_turn()


func draw_cards() -> void:
	var card

	if cards.size() < 2:
		for i in range(2):
			card = randi_range(1, 9)
			$MonitorCards.show_card(card)
			cards.append(card)
	elif cards.size() < 5:
		card = randi_range(1, 9)
		cards.append(card)
		$MonitorCards.show_card(card)


func calculate_total() -> int:
	var total = 0
	for card in cards:
		total += card

	game_manager.player_total = total
	return total


func _on_stay_button_pressed():
	audio_manager.play_sfx("button_press");
	main.screen_shake()

	game_manager.player_total = calculate_total()
	game_manager.claimed_player_total = calculate_total()

	$Labels/ActualTotalLabel.text = "Actual Total: " + str(game_manager.player_total)
	$Labels/ClaimedTotalLabel.text = "Claimed Total: " + str(game_manager.claimed_player_total)

	game_manager.player_state = game_manager.State.BLUFF
	game_manager.end_turn()

	await to_phase_2()

	if game_over:
		return


func to_phase_1() -> void:
	print("Phase 1 is being called")

	draw_buttons.visible = false
	bluff_buttons.visible = false

	showdown_buttons.visible = true
	showdown_buttons.get_child(0)._on_change_to_truth()
	await showdown_buttons.get_child(0).anim.animation_finished
	showdown_buttons.get_child(1)._on_change_to_truth()
	await showdown_buttons.get_child(1).anim.animation_finished
	showdown_buttons.visible = false

	draw_buttons.visible = true


func to_phase_2() -> void:	
	print("Phase 2 is being called")

	draw_buttons.visible = true
	draw_buttons.get_child(0)._on_change_to_truth()
	await draw_buttons.get_child(0).anim.animation_finished
	draw_buttons.get_child(1)._on_change_to_truth()
	await draw_buttons.get_child(1).anim.animation_finished

	draw_buttons.visible = false
	bluff_buttons.visible = true

	bluff_buttons.get_child(0).visible = true
	bluff_buttons.get_child(1).visible = true

	showdown_buttons.visible = false
	bluff_input_panel.visible = false


func to_phase_3() -> void:
	print("Phase 3 is being called")

	bluff_buttons.visible = true
	bluff_buttons.get_child(0)._on_change_to_truth()
	await bluff_buttons.get_child(0).anim.animation_finished
	bluff_buttons.get_child(1)._on_change_to_truth()
	await bluff_buttons.get_child(1).anim.animation_finished

	bluff_buttons.visible = false
	draw_buttons.visible = false

	showdown_buttons.get_child(0)._on_idle()
	showdown_buttons.get_child(1)._on_idle()
	showdown_buttons.visible = true


func to_enemy_turn() -> void:
	draw_buttons.visible = false
	bluff_buttons.visible = false
	bluff_input_panel.visible = false


func _on_bluff_button_pressed():
	audio_manager.play_sfx("button_press");
	print("Bluff button pressed")

	if game_over:
		return

	main.screen_shake()
	await bluff_buttons.get_child(0).anim.animation_finished

	$Labels/OpponentActionLabel.text = "Opponent: Choose bluff number"

	bluff_buttons.get_child(0).visible = false
	bluff_buttons.get_child(1).visible = false

	#tens_digit = 0
	#ones_digit = 0
	#bluff_display.show_number(tens_digit, ones_digit)
	bluff_input_panel._set_visible();

func _on_truth_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	
	if game_over:
		return

	main.screen_shake()
	await bluff_buttons.get_child(1).anim.animation_finished
	
	claimed_total = calculate_total();
	game_manager.claimed_player_total = claimed_total;
	game_manager.player_total = claimed_total;
	
	print(claimed_total)
	$Labels/ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total);

	bluff_input_panel.visible = false

	game_manager.player_state = game_manager.State.SHOWDOWN
	game_manager.end_turn()


func _on_enter_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	if game_over:
		return

	main.screen_shake()

	claimed_total = tens_digit * 10 + ones_digit
	game_manager.claimed_player_total = claimed_total
	$Labels/ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total);

	bluff_input_panel.visible = false

	game_manager.player_state = game_manager.State.SHOWDOWN
	game_manager.end_turn()


func set_buttons_enabled(enabled):
	$ActionButton/DrawCardButton.disabled = not enabled
	$ActionButton/StayButton.disabled = not enabled
	$BluffUI/BluffButton.disabled = not enabled
	$BluffUI/TruthButton.disabled = not enabled


func _on_call_bluff_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	if game_over:
		return

	main.screen_shake()
	game_manager.player_call_bluff()


func _on_pass_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	if game_over:
		return

	main.screen_shake()
	game_manager.player_pass_bluff()


func _on_restart_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	emit_signal("restart_game")


func _replay_button_pressed():
	audio_manager.play_sfx("button_press");
	print("Replay pressed")
	get_tree().reload_current_scene()


func _next_level_button_pressed():
	audio_manager.play_sfx("button_press");
	print("Next Level Pressed")
	get_tree().change_scene_to_file("res://Scenes/Level 3.tscn")


func _on_replay_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	get_tree().reload_current_scene()


func _on_next_level_button_pressed() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	var file_name = current_scene_path.get_file().get_basename()

	var level_text = file_name.replace("Level", "").strip_edges()
	var current_level = int(level_text)

	var next_level = current_level + 1
	var next_scene_path = "res://Scenes/Level" + str(next_level) + ".tscn"

	if ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("No more levels!")

func _on_main_menu_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	get_tree().change_scene_to_file("res://Scenes/Prefabs/Main_Menu.tscn")


func _draw_powerup() -> void:
	
	print("Before powerup: ", cards)
	var changed_card_position: int = randi_range(0, 1)
	var new_value: int = randi_range(1, 9)

	cards[changed_card_position] = new_value

	print("After powerup: ", cards)
	monitor_cards.show_hand(cards)
	
func _hand_powerup() -> void:
	print("HAND IS CHANGING");
	print("Before powerup: ", cards)
	
	var changed_card_position: int = randi_range(0, cards.size() - 1);
	var new_value: int = randi_range(1, 9);
	
	cards[changed_card_position] = new_value;
	
	print("After powerup: ", cards);
	monitor_cards.show_hand(cards)


#func _on_button_0_pressed() -> void:
	#print("0")
	#keypad_press("0")
#
#func _on_button_1_pressed() -> void:
	#print("1")
	#keypad_press("1")
#
#func _on_button_2_pressed() -> void:
	#print("2")
	#keypad_press("2")
#
#func _on_button_3_pressed() -> void:
	#print("3")
	#keypad_press("3")
#
#func _on_button_4_pressed() -> void:
	#print("4")
	#keypad_press("4")
#
#func _on_button_5_pressed() -> void:
	#print("5")
	#keypad_press("5")
#
#func _on_button_6_pressed() -> void:
	#print("6")
	#keypad_press("6")
#
#func _on_button_7_pressed() -> void:
	#print("7")
	#keypad_press("7")
#
#func _on_button_8_pressed() -> void:
	#print("8")
	#keypad_press("8")
#
#func _on_button_9_pressed() -> void:
	#print("9")
	#keypad_press("9")
