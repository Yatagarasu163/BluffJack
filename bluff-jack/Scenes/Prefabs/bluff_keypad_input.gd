extends Node2D

var tens_digit := 0
var ones_digit := 0

@onready var bluff_keypad = $bluffkeypad
@onready var tens_sprite = $bluffkeypad/TensDigit
@onready var ones_sprite = $bluffkeypad/OnesDigit
@onready var bluff_btn = $"../BluffUI/BluffButton";

var digit_textures = {
	0: preload("res://Assets/cards/0.png"),
	1: preload("res://Assets/cards/1.png"),
	2: preload("res://Assets/cards/2.png"),
	3: preload("res://Assets/cards/3.png"),
	4: preload("res://Assets/cards/4.png"),
	5: preload("res://Assets/cards/5.png"),
	6: preload("res://Assets/cards/6.png"),
	7: preload("res://Assets/cards/7.png"),
	8: preload("res://Assets/cards/8.png"),
	9: preload("res://Assets/cards/9.png")
}

func _ready():
	update_keypad_display()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	bluff_keypad.visible = false

func update_keypad_display() -> void:
	tens_sprite.texture = digit_textures[tens_digit]
	ones_sprite.texture = digit_textures[ones_digit]

func keypad_press(value: int) -> void:
	print("keypad pressed: ", value)

	var tens_visual = bluff_keypad.get_child(0);
	var ones_visual = bluff_keypad.get_child(1);

	if value >= 0:
		tens_digit = ones_digit;
		ones_digit = int(value);
	if value == -1:
		if tens_digit > 0:
			ones_digit = tens_digit;
			tens_digit = 0
		elif ones_digit > 0:
			ones_digit = 0;
	if value == -2:
		_on_confirm_button_pressed();

	#tens_digit = ones_digit
	#ones_digit = int(value)

	update_keypad_display()



func _on_confirm_button_pressed() -> void:

	var claimed_total = tens_digit * 10 + ones_digit
	game_manager.claimed_player_total = claimed_total
	$"../Labels/ClaimedTotalLabel".text = "Claimed Total: " + str(claimed_total)

	bluff_keypad.visible = false

	game_manager.player_state = game_manager.State.SHOWDOWN
	game_manager.end_turn()
	 
func show_number() -> void:
	var tens_visual = bluff_keypad.get_child(0);
	var ones_visual = bluff_keypad.get_child(1);
	
	if tens_digit > 0:
		tens_visual.visible = true;
	if tens_visual.visible == true:
		ones_visual.visible = true;
	else:
		if ones_visual != 0:
			ones_visual.visible = true;
		else:
			ones_visual.visible = false;

func _set_visible() -> void:
	visible = true;
	print("I am visible!");
	bluff_keypad.visible = true;
	print("Keypad is visible: ", bluff_keypad.visible);
