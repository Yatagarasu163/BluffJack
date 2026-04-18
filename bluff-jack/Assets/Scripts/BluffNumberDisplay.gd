extends Node2D

var digit_textures = {}
var slot_nodes = []
var shown_digits = []

func _ready():
	for i in range(0, 10):
		digit_textures[i] = load("res://Assets/cards/%d.png" % i)

	slot_nodes = [
		$TensDigit,
		$OnesDigit
	]

	show_number(0, 0)

func show_number(tens: int, ones: int) -> void:
	clear_digits()

	var values = [tens, ones]

	for i in range(values.size()):
		var slot = slot_nodes[i]
		var digit_value = values[i]

		var digit_sprite = Sprite2D.new()
		digit_sprite.texture = digit_textures[digit_value]
		digit_sprite.position = slot.position
		digit_sprite.scale = Vector2(1, 1)
		digit_sprite.modulate.a = 1.0

		add_child(digit_sprite)
		shown_digits.append(digit_sprite)

func clear_digits() -> void:
	for digit in shown_digits:
		if is_instance_valid(digit):
			digit.queue_free()

	shown_digits.clear()
