extends Node2D

@onready var anim = $PlayerSprite;
@onready var knife_anim = $KnifeSprite;
@export var min_anim_speed = 0.8;
@export var max_anim_speed = 1.5;
@onready var ten_visual = $ChatBubbleSprite/TensDigit;
@onready var one_visual = $ChatBubbleSprite/OnesDigit;
@onready var chat_visual = $ChatBubbleSprite;
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
var card_textures = {};
var anim_state = AnimState.IDLE;

func _ready() -> void:
	
	chat_visual.visible = false;
	
	for i in range(0, 10):
		card_textures[i] = load("res://Assets/cards/%d.png" % i)
	
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
		knife_anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		audio_manager.play_sfx("knife_pull_out");
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
					await anim.animation_finished;
					audio_manager.play_sfx("button_press");
				AnimState.CALL_BLUFF:
					anim.play("call_bluff");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.PASS:
					anim.play("pass");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
		2:
			knife_anim.visible = true;
			knife_anim.play("pull_out");
			audio_manager.play_sfx("knife_pull_out");
			knife_anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
			match anim_state:
				AnimState.IDLE:
					anim.play("idle");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.SELECT:
					anim.play("select");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
					await anim.animation_finished;
					audio_manager.play_sfx("button_press");
				AnimState.CALL_BLUFF:
					anim.play("call_bluff");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.PASS:
					anim.play("pass");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
			
		1: 
			knife_anim.visible = false;
			audio_manager.play_sfx("crying_voiceline");
			match anim_state:
				AnimState.IDLE:
					anim.play("knife_idle");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.SELECT:
					anim.play("knife_select");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
					await anim.animation_finished;
					audio_manager.play_sfx("button_press");
				AnimState.CALL_BLUFF:
					anim.play("knife_call_bluff");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
				AnimState.PASS:
					anim.play("knife_pass");
					anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);

func claim_anim(claimed_total: int) -> void:
	var ten_digit = int(claimed_total / 10);
	var one_digit = int(claimed_total % 10);
	
	ten_visual.texture = card_textures[ten_digit];
	one_visual.texture = card_textures[one_digit];
	
	chat_visual.visible = true;
	await get_tree().create_timer(3.0).timeout;
	chat_visual.visible = false;
		

func _on_idle_finished() -> void:
	if enemy_life > 1:
		anim.play("idle");
	else: 
		anim.play("knife_idle");
	anim.speed_scale = randf_range(min_anim_speed, max_anim_speed);
	print(anim.speed_scale);
