extends Button

@onready var anim = $AnimatedSprite2D;

func _ready() -> void:
	mouse_entered.connect(_on_hover);
	mouse_exited.connect(_on_idle);
	pressed.connect(_on_pressed);

func _on_hover() -> void:
	await anim.animation_finished;
	anim.play("hover");

func _on_idle() -> void:
	await anim.animation_finished;
	anim.play("idle");

func _on_pressed() -> void:
	await anim.animation_finished;
	anim.play("pressed");

func _on_change_to_truth() -> void:
	anim.play("change");
