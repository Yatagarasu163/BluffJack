extends Button

var mouse_enter = false;
@onready var anim = $AnimatedSprite2D;

func _ready() -> void:
	$".".mouse_entered.connect(_on_hover);
	$".".mouse_exited.connect(_on_idle);
	$".".pressed.connect(_on_pressed);

func _on_hover() -> void:
	mouse_enter = true;
	position.y += 2;
	anim.play("hover");

func _on_idle() -> void:
	if mouse_enter:
		position.y -= 2;
		mouse_enter = false;
	anim.play("idle");

func _on_pressed() -> void:
	anim.play("pressed");
	
func _on_change_to_truth() -> void:
	anim.play("change");
