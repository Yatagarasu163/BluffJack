extends Node2D

@export var number = 0;
@onready var button = $Button;
@onready var anim = $AnimatedSprite2D;
@onready var sprite = $AnimatedSprite2D/Sprite2D;
var number_textures = {};
var mouse_entered = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0, 10):
		number_textures[i] = load("res://Assets/cards/%d.png" % i)
	
	sprite.texture = number_textures[number];
	
	button.mouse_entered.connect(_on_hover);
	button.mouse_exited.connect(_on_idle);
	button.pressed.connect(_on_pressed);
	
func _on_hover() -> void:
	mouse_entered = true;
	anim.play("hover");
	sprite.position.y += 2;

func _on_idle() -> void:
	if mouse_entered == true:
		sprite.position.y -= 2;
		mouse_entered = false;
	anim.play("idle");

func _on_pressed() -> void:
	anim.play("pressed");
