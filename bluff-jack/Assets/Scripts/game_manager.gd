extends Node2D

enum Turn {PLAYER, ENEMY}
enum State {DRAW, BLUFF, SHOWDOWN}
var player_turn = null;
signal current_turn(turn: Turn);
signal start_game;
var player_ready = false;
var enemy_ready = false;
var claimed_player_total = 0;
var player_total = 0;
var enemy_claimed_total = 0;
var enemy_total = 0;
@onready var player = get_tree().get_first_node_in_group("Player");
@onready var enemy = get_tree().get_first_node_in_group("Enemy");
var player_life_label = null;
var opponent_life_label = null;
var player_state = State.DRAW;
var enemy_state = State.DRAW;
var processing_turn = false;


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

func _on_restart_game() -> void:
	start_match();
	player_state = State.DRAW;
	enemy_state = State.DRAW;

func register_player(p) -> void:
	player = p;
	print("Player node:", player)
	print("Script attached:", player.get_script())
	print("Has player_life?", "player_life" in player)
	player_life_label = player.get_node("PlayerLifeLabel");
	opponent_life_label = player.get_node("OpponentLifeLabel");
	player_ready = true;
	player.restart_game.connect(_on_restart_game);
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
	player_state = State.DRAW;
	enemy_state = State.DRAW;
	if randf() < 1:
		player_turn = Turn.PLAYER;
		emit_signal("current_turn", Turn.PLAYER);
	else:
		player_turn = Turn.ENEMY;
		emit_signal("current_turn", Turn.ENEMY);

func end_turn() -> void:
	if processing_turn:
		return;
		
	processing_turn = true;
	
	if player_turn == Turn.PLAYER:
		print("Enemy Turn");
		player_turn = Turn.ENEMY;
	else:
		print("Player Turn");
		player_turn = Turn.PLAYER;
		
	await get_tree().process_frame
	processing_turn = false;
	emit_signal("current_turn", player_turn);

func player_call_bluff():
	if enemy_claimed_total != enemy_total:
		print("Player wins bluff callout!");
	else:
		print("Player loses bluff callout!");

# Normal Result without bluffing 
func resolve_normal_result():
	var winner = get_winner(claimed_player_total, enemy_claimed_total);

	if winner == "player":
		opponent_loses_round("Result: You Win! Opponent had " + str(enemy.calculateTotal()))
	elif winner == "opponent":
		player_loses_round("Result: You Lose! Opponent had " + str(enemy.calculateTotal()));;
	else:
		$ResultLabel.text = "Result: Draw! Opponent had " + str(enemy.calculateTotal());
		player.game_over = true
		player.to_phase_1();	


#Winning Logic
func get_winner(input_player_total, enemy_total):
	if input_player_total == 21 and enemy_total != 21:
		return "player"
	elif enemy_total == 21 and input_player_total != 21:
		return "opponent"
	elif input_player_total == 21 and enemy_total == 21:
		return "draw"

	if input_player_total <= 21 and enemy_total > 21:
		return "player"
	elif enemy_total <= 21 and input_player_total > 21:
		return "opponent"

	if input_player_total <= 21 and enemy_total <= 21:
		if input_player_total > enemy_total:
			return "player"
		elif enemy_total > input_player_total:
			return "opponent"
		else:
			return "draw"

	if input_player_total > 21 and enemy_total > 21:
		var player_diff = input_player_total - 21
		var enemy_diff = enemy_total - 21

		if player_diff < enemy_diff:
			return "player"
		elif enemy_diff < player_diff:
			return "opponent"
		else:
			return "draw"

	return "draw"
	
	

#Updating Life labels
func update_life_labels():
	if player_life_label == null || opponent_life_label == null:
		return
	
	player_life_label.text = "Player Life: " + str(player.get_life())
	opponent_life_label.text = "Opponent Life: " + str(enemy.life_total);
	
# If the opponent loses the round
func opponent_loses_round(message):
	enemy.life_total -= 1;
	update_life_labels()
	$ResultLabel.text = message
	$BluffUI/Control/BluffInput.visible = false
	
	$MonitorCards.clear_cards()
	
	if enemy.life_total <= 0:
		$ResultLabel.text = message + " You win " 
	
	player.game_over = true
	player.to_phase_1();
	
# When Player Loses the round 
func player_loses_round(message):
	player.player_life -= 1
	update_life_labels()
	$ResultLabel.text = message
	$BluffUI/Control/BluffInput.visible = false
	
	$MonitorCards.clear_cards()
	
	if player.player_life <= 0:
		$ResultLabel.text = message + " Game Over! You lose the match."
	
	player.game_over = true
	player.to_phase_1();
	
