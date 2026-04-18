extends Button


func _ready() -> void:
	pressed.connect(_return);

func _return() -> void:
	get_tree().change_scene_to_file("res://Scenes/Prefabs/Main_Menu.tscn");
