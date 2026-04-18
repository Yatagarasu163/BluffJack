extends Node2D

@onready var bgm = $BGM;
@onready var sfx = $SFX;

var music_library = {
	"bgm": preload("res://Assets/music/A Dangerous Game of Chance.mp3")
}

var sfx_library = {
	"knife_pull_out": preload("res://Assets/music/knife_pull_out.mp3"),
	"button_press": preload("res://Assets/music/button_press.mp3"),
	"crying_voiceline": preload("res://Assets/music/crying_voiceline.mp3"),
	"i_have_voiceline": preload("res://Assets/music/i_have_voiceline.mp3")
}

var sfx_players = []
var max_players = 8;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_music("bgm");
	
	for i in range(max_players):
		var player = AudioStreamPlayer.new();
		add_child(player);
		sfx_players.append(player);


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

func play_sfx(name: String):
	if not sfx_library.has(name):
		return
		
	for player in sfx_players:
		if not player.playing:
			var random_pitch = randf_range(0.5, 1.5);
			player.pitch_scale = random_pitch;
			player.stream = sfx_library[name];
			player.play();
			return;
