var tens_digit := 0
var ones_digit := 0

@onready var bluff_keypad = $BluffUI/bluffkeypad
@onready var tens_sprite = $BluffUI/bluffkeypad/TensDigit
@onready var ones_sprite = $BluffUI/bluffkeypad/OnesDigit

var digit_textures = {
	0: preload("res://assets/cards/0.png"),
	1: preload("res://assets/cards/1.png"),
	2: preload("res://assets/cards/2.png"),
	3: preload("res://assets/cards/3.png"),
	4: preload("res://assets/cards/4.png"),
	5: preload("res://assets/cards/5.png"),
	6: preload("res://assets/cards/6.png"),
	7: preload("res://assets/cards/7.png"),
	8: preload("res://assets/cards/8.png"),
	9: preload("res://assets/cards/9.png")
}

func _ready():
	update_keypad_display()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	start_match()
	game_manager.register_player(self)
	game_manager.current_turn.connect(_on_turn_changed)
	game_manager.start_game.connect(_on_match_started)
	bluff_keypad.visible = false

func update_keypad_display() -> void:
	tens_sprite.texture = digit_textures[tens_digit]
	ones_sprite.texture = digit_textures[ones_digit]

func _on_bluff_button_pressed():
	print("Bluff button pressed")
	if game_over:
		return

	main.screen_shake()
	await bluff_buttons.get_child(0).anim.animation_finished

	$Labels/OpponentActionLabel.text = "Opponent: Choose bluff number"
	bluff_buttons.visible = true
	bluff_buttons.get_child(0).visible = false
	bluff_buttons.get_child(1).visible = false

	tens_digit = 0
	ones_digit = 0
	update_keypad_display()

	bluff_keypad.visible = true

func keypad_press(value: String) -> void:
	print("keypad pressed: ", value)

	if !value.is_valid_int():
		return

	tens_digit = ones_digit
	ones_digit = int(value)

	update_keypad_display()

	claimed_total = tens_digit * 10 + ones_digit
	game_manager.claimed_player_total = claimed_total

func _on_confirm_button_pressed() -> void:
	if game_over:
		return

	main.screen_shake()

	claimed_total = tens_digit * 10 + ones_digit
	game_manager.claimed_player_total = claimed_total
	$Labels/ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)

	bluff_keypad.visible = false

	game_manager.player_state = game_manager.State.SHOWDOWN
	game_manager.end_turn()
	 
