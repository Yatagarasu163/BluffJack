extends Node2D

@onready var anim = $AnimatedSprite2D;
@onready var btn = $Button;
@export var value = 0;
var is_pressed_anim = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	btn.mouse_entered.connect(_on_hover);
	btn.mouse_exited.connect(_on_idle);
	btn.pressed.connect(_on_pressed);

func _on_hover() -> void:
	if is_pressed_anim:
		return;
	anim.play("hover");

func _on_idle() -> void:
	if is_pressed_anim:
		return;
	anim.play("idle");

func _on_pressed() -> void:
	is_pressed_anim = true;
	
	anim.play("pressed");
	anim.speed_scale = 3.5;
	await anim.animation_finished;
	
	is_pressed_anim = false;
	
	_return_button_value();
	
func _return_button_value() -> int:
	return value;
