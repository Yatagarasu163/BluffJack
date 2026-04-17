extends Node2D

#Scren Shake Values
@export var shake_strength_min: float = 2.0
@export var shake_strength_max: float = 6.0
@export var shake_count: int = 4
@export var shake_speed: float = 0.03
@export var return_speed: float = 0.05

func screen_shake():
	var original_pos = position
	
	var tween = create_tween()
	
	for i in range(shake_count):
		var strength = randf_range(shake_strength_min,shake_strength_max)
		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		
		tween.tween_property(self, "position", original_pos + offset, 0.03)
	#Returning it to the original Position
	tween.tween_property(self, "position", original_pos, 0.05)
