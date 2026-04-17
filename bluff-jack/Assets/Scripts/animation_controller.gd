extends Node2D

@onready var player = $"..";
@onready var anim = $knifeAnim;
@export var min_anim_speed = 0.8;
@export var max_anim_speed = 1.5;

func _update_life_anim(player_life : int) -> void:
	match player_life:
		3:
			anim.visible = false;
		2: 
			anim.visible = true;
			anim.play("warning");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		1:
			anim.visible = true;
			anim.play("warning");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
