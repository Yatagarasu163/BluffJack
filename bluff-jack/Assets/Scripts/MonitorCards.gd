extends Node2D

var card_textures = {}
var slot_nodes = []
var shown_cards = []

func _ready():
	for i in range(1, 10):
		card_textures[i] = load("res://Assets/cards/%d.png" % i)

	slot_nodes = [
		$Slot1,
		$Slot2,
		$Slot3,
		$Slot4,
		$Slot5
	]

func show_card(card_value: int):
	if shown_cards.size() >= slot_nodes.size():
		return

	var slot = slot_nodes[shown_cards.size()]

	var card_sprite = Sprite2D.new()
	card_sprite.texture = card_textures[card_value]
	card_sprite.position = slot.position
	card_sprite.scale = Vector2(1, 1)
	card_sprite.modulate.a = 0.0

	add_child(card_sprite)
	shown_cards.append(card_sprite)

	var tween = create_tween()
	#Fade in Value
	tween.tween_property(card_sprite, "modulate:a", 1.0, 0.25)

func clear_cards():
	for card in shown_cards:
		if is_instance_valid(card):
			var tween = create_tween()
			#Fade Out 
			tween.tween_property(card, "modulate:a", 0.0, 0.25)
			
			#Waiting for th fade to end before removing the card numbers 
			tween.tween_callback(func():
				if is_instance_valid(card):
					card.queue_free()
			)

	shown_cards.clear()
	
func show_hand(card_values: Array) -> void:
	clear_cards()
	
	for value in card_values:
		show_card(value)
