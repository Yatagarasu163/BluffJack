extends Node2D

@onready var anim = $AnimatedSprite2D;
@export var minimum_idle_animation_speed = 0.8;
@export var maximum_idle_animation_speed = 1.5;
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
	anim.speed_scale = randf_range(minimum_idle_animation_speed, maximum_idle_animation_speed);
	print(anim.speed_scale);
	anim.animation_finished.connect(_on_idle_finished);

func set_anim_state(new_state: int) -> void:
	if anim_state == new_state:
		return;
	
	#anim_state = new_state;
	#match anim_state:
		#AnimState.IDLE:
			#anim.play

func _on_select_option() -> void:
	anim.play()

func _on_idle_finished() -> void:
	anim.play("idle");
	anim.speed_scale = randf_range(minimum_idle_animation_speed, maximum_idle_animation_speed);
	print(anim.speed_scale);
