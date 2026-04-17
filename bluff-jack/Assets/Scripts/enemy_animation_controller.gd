extends Node2D

@onready var anim = $AnimatedSprite2D;
@export var min_anim_speed = 0.8;
@export var max_anim_speed = 1.5;
enum AnimState {
	IDLE,
	SELECT,
	KNIFE_IDLE,
	KNIFE_SELECT,
	CALL_BLUFF,
	PASS,
	KNIFE_CALL_BLUFF,
	KNIFE_PASS
}
var anim_state = AnimState.IDLE;

func _ready() -> void:
	anim.play("idle");
	anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
	print(anim.speed_scale);
	anim.animation_finished.connect(_on_idle_finished);

func set_anim_state(new_state: int) -> void:
	if anim_state == new_state:
		return;
	
	anim_state = new_state as AnimState;
	match anim_state:
		AnimState.IDLE:
			anim.play("idle");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		AnimState.SELECT:
			anim.play("select");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		AnimState.KNIFE_IDLE:
			anim.play("knife_idle");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		AnimState.KNIFE_SELECT:
			anim.play("knife_select");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		AnimState.CALL_BLUFF:
			anim.play("call_bluff");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		AnimState.PASS:
			anim.play("pass");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		AnimState.KNIFE_CALL_BLUFF:
			anim.play("knife_call_bluff");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		AnimState.KNIFE_PASS:
			anim.play("knife_pass");
			anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);

func _on_select_option() -> void:
	anim.play()

func _on_idle_finished() -> void:
	anim.play("idle");
	anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
	print(anim.speed_scale);
