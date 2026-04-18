extends Node2D

@onready var bgm = $BGM;
@onready var sfx = $SFX;

var music_library = {
	"bgm": preload("res://Assets/music/A Dangerous Game of Chance.mp3")
}

var sfx_library = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_music("bgm");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func play_music(music_name: String) -> void:
	if not music_library.has(music_name):
		return
	
	if bgm.stream == music_library[music_name]:
		return # already playing the music
	
	bgm.stream = music_library[music_name];
	bgm.play();
