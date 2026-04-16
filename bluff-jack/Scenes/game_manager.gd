extends Node2D

enum Turn {PLAYER, ENEMY}
var player_turn = null;
signal current_turn(turn: Turn);
signal start_game;
var player_ready = false;
var enemy_ready = false;

#Turn mechanics: 
#1) Flip a coin (winner starts)
#2) Make a choice, pass the turn
#3) If stays, the next one gets to choose their actions until they stay also
#4) Both choose to either reveal or bluff
#5) If one bluff, then other gets to choose to trust or not
#6) If neither bluffs, compare two numbers
#7) If both bluffs, both choose whether to accept the bluff or not.
#8) Calculate who wins, then display the winner and trigger round end stuff

func _ready() -> void:
	pass

func register_player() -> void:
	player_ready = true;
	_try_start();
	
func register_enemy() -> void:
	enemy_ready = true;
	_try_start();
	
func _try_start():
	if player_ready and enemy_ready:
		print("All systems ready. Starting game.");
		start_match();
	

func start_match() -> void:
	emit_signal("start_game");
	#if randf() < 0.5:
		#player_turn = Turn.PLAYER;
		#emit_signal("current_turn", Turn.PLAYER);
	#else:
	player_turn = Turn.ENEMY;
	emit_signal("current_turn", Turn.ENEMY);

func end_turn() -> void:
	if player_turn == Turn.PLAYER:
		player_turn = Turn.ENEMY;
		emit_signal("current_turn", Turn.ENEMY);
	else:
		player_turn = Turn.PLAYER;
		emit_signal("current_turn", Turn.PLAYER);
		
