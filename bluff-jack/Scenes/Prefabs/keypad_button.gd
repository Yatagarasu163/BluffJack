extends Node2D

@export var button_value: String = ""

@onready var button = $button
@onready var anim = $AnimatedSprite2D
var mouse_entered := false

func _ready() -> void:
	anim.play("idle")
	
	button.mouse_entered.connect(_on_hover)
	button.mouse_entered.connect(_on_idle)
	button.mouse_entered.connect(_on_pressed)

func _on_hover() ->void:
	anim.play("hover")
	
func _on_idle() -> void:
	anim.play("idle")

func _on_pressed() -> void:
	anim.play("pressed")
	
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		player.keypad_press_press(button_value)

func _on_anim_finished() -> void:
	if anim.animation == "pressed":
		if mouse_entered:
			anim.play("hover")
		else:
			anim.play("idle")
	

	 
