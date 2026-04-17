extends Node2D

@onready var anim = $PlayerSprite;
@onready var knife_anim = $KnifeSprite;
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
@onready var enemy_life = $"..".life_total;
var anim_state = AnimState.IDLE;

func _ready() -> void:
	knife_anim.visible = false;
	if enemy_life > 1:
		anim.play("idle");
	else:
		anim.play("knife_idle");
	anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
	print(anim.speed_scale);
	anim.animation_finished.connect(_on_idle_finished);
	
func _update_knife(has_knife: bool) -> void:
	if has_knife:
		knife_anim.visible = true;
		knife_anim.play("pull_out");
		await knife_anim.animation_finished
		knife_anim.play("knife_idle")
		knife_anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
	else:
		knife_anim.visible = false;


func set_anim_state(new_state: int) -> void:
	if anim_state == new_state:
		return;
	
	anim_state = new_state as AnimState;
	match enemy_life:
		3:
			knife_anim.visible = false;
			match anim_state:
				AnimState.IDLE:
					anim.play("idle");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.SELECT:
					anim.play("select");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.CALL_BLUFF:
					anim.play("call_bluff");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.PASS:
					anim.play("pass");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		2:
			knife_anim.visible = true;
			knife_anim.play("pull_out");
			knife_anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
			match anim_state:
				AnimState.IDLE:
					anim.play("idle");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.SELECT:
					anim.play("select");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.CALL_BLUFF:
					anim.play("call_bluff");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.PASS:
					anim.play("pass");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
			
		1: 
			knife_anim.visible = false;
			match anim_state:
				AnimState.IDLE:
					anim.play("knife_idle");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.SELECT:
					anim.play("knife_select");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.CALL_BLUFF:
					anim.play("knife_call_bluff");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.PASS:
					anim.play("knife_pass");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);

func _on_select_option() -> void:
	anim.play()

func _on_idle_finished() -> void:
	if enemy_life > 1:
		anim.play("idle");
	else: 
		anim.play("knife_idle");
	anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
	print(anim.speed_scale);
