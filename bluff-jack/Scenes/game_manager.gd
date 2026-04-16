extends Node2D

var is_player_turn = false;

#Turn mechanics: 
#1) Flip a coin (winner starts)
#2) Make a choice, pass the turn
#3) If stays, the next one gets to choose their actions until they stay also
#4) Both choose to either reveal or bluff
#5) If one bluff, then other gets to choose to trust or not
#6) If neither bluffs, compare two numbers
#7) If both bluffs, both choose whether to accept the bluff or not.
#8) Calculate who wins, then display the winner and trigger round end stuff

@onready var player = get_tree().get_nodes_in_group("Player")[0];

func _ready() -> void:
	print(player.is_player_turn);

func start_match() -> void:
	is_player_turn = randf() < 0.5;
	player.start_match();
	player.start_round();
	if is_player_turn:
		player.is_player_turn = true;
	pass
