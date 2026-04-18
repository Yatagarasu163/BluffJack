extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed_scale = 0.25
	play("default");
