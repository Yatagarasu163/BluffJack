extends Button

@onready var anim = $AnimatedSprite2D;

func _ready() -> void:
	$".".mouse_entered.connect(_on_hover);
	$".".mouse_exited.connect(_on_idle);
	$".".pressed.connect(_on_pressed);

func _on_hover() -> void:
	anim.play("hover");

func _on_idle() -> void:
	anim.play("idle");

func _on_pressed() -> void:
	anim.play("pressed");
