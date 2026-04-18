extends Node2D

func _on_start_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	get_tree().change_scene_to_file("res://Scenes/Levels/Level 1.tscn")

func _on_rule_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	get_tree().change_scene_to_file("res://Scenes/Prefabs/Rulebook.tscn")

func  _on_option_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	get_tree().change_scene_to_file("res://Scenes/Prefabs/Options.tscn")
	
func _on_exit_button_pressed() -> void:
	audio_manager.play_sfx("button_press");
	get_tree().quit()
