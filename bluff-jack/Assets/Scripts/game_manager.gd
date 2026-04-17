extends Node2D

enum Turn {PLAYER, ENEMY}
enum State {DRAW, BLUFF, SHOWDOWN}
var player_turn = null
signal current_turn(turn: Turn)
signal start_game
var player_ready = false
var enemy_ready = false
var claimed_player_total = 0
var player_total = 0
var enemy_claimed_total = 0
var enemy_total = 0
var player_calls_bluff = false
var enemy_calls_bluff = false
var player_lied = false
var enemy_lied = false
var player_made_showdown_choice = false
var enemy_made_showdown_choice = false
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var enemy = get_tree().get_first_node_in_group("Enemy")
var player_life_label = null
var opponent_life_label = null
var player_state = State.DRAW
var enemy_state = State.DRAW
var processing_turn = false


func _ready() -> void:
	pass

# Restart the whole match when restart signal is used
func _on_restart_game() -> void:
	start_match()
	player_state = State.DRAW
	enemy_state = State.DRAW

func register_player(p) -> void:
	player = p
	player_life_label = player.get_node("Labels/PlayerLifeLabel")
	opponent_life_label = player.get_node("Labels/OpponentLifeLabel")
	player_ready = true
	player.restart_game.connect(_on_restart_game)
	_try_start()

func register_enemy() -> void:
	enemy_ready = true
	_try_start()


func _try_start():
	if player_ready and enemy_ready:
		print("All systems ready. Starting game.")
		start_match()
		

func start_match() -> void:
	reset_round_flags()
	emit_signal("start_game")

	player_state = State.DRAW
	enemy_state = State.DRAW

	if enemy != null and enemy.has_method("reset_for_new_round"):
		enemy.reset_for_new_round()

	if randf() < 0.5:
		player_turn = Turn.PLAYER
		emit_signal("current_turn", Turn.PLAYER)
	else:
		player_turn = Turn.ENEMY
		emit_signal("current_turn", Turn.ENEMY)


func end_turn() -> void:
	if processing_turn:
		return

	processing_turn = true

	if player_turn == Turn.PLAYER:
		player_turn = Turn.ENEMY
	else:
		player_turn = Turn.PLAYER

	await get_tree().process_frame
	processing_turn = false
	emit_signal("current_turn", player_turn)


func reset_round_flags() -> void:
	player_calls_bluff = false
	enemy_calls_bluff = false
	player_lied = false
	enemy_lied = false
	player_made_showdown_choice = false
	enemy_made_showdown_choice = false


func update_lie_flags() -> void:
	player_lied = (claimed_player_total != player_total)
	enemy_lied = (enemy_claimed_total != enemy_total)


func try_resolve_showdown() -> void:
	if player_made_showdown_choice and enemy_made_showdown_choice:
		resolve_showdown()


# This compares totals using your 21 rules
# 21 is best
# <=21 always beats >21
# if both on same side, closer/higher according to the rules wins

func get_winner(input_player_total, enemy_input_total):
	if input_player_total == 21 and enemy_input_total != 21:
		return "player"
	elif enemy_input_total == 21 and input_player_total != 21:
		return "opponent"
	elif input_player_total == 21 and enemy_input_total == 21:
		return "draw"

	if input_player_total <= 21 and enemy_input_total > 21:
		return "player"
	elif enemy_input_total <= 21 and input_player_total > 21:
		return "opponent"

	if input_player_total <= 21 and enemy_input_total <= 21:
		if input_player_total > enemy_input_total:
			return "player"
		elif enemy_input_total > input_player_total:
			return "opponent"
		else:
			return "draw"

	if input_player_total > 21 and enemy_input_total > 21:
		var player_diff = input_player_total - 21
		var enemy_diff = enemy_input_total - 21

		if player_diff < enemy_diff:
			return "player"
		elif enemy_diff < player_diff:
			return "opponent"
		else:
			return "draw"

	return "draw"



func resolve_showdown() -> void:
	update_lie_flags()

	# CASE 1: BOTH called bluff
	if player_calls_bluff and enemy_calls_bluff:

		# Both were bluffing:
		# use ACTUAL totals and compare them
		if player_lied and enemy_lied:
			var winner_both_bluff = get_winner(player_total, enemy_total)

			if winner_both_bluff == "player":
				opponent_loses_round(
					"Result: Both players bluffed and both got called! Your actual total = " + str(player_total) +
					", Opponent actual total = " + str(enemy_total)
				)
			elif winner_both_bluff == "opponent":
				player_loses_round(
					"Result: Both players bluffed and both got called! Your actual total = " + str(player_total) +
					", Opponent actual total = " + str(enemy_total)
				)
			else:
				player.get_node("ResultLabel").text = (
					"Result: Both players bluffed and both got called! Draw! Your actual total = " + str(player_total) +
					", Opponent actual total = " + str(enemy_total)
				)
				player.get_node("BluffUI/Control/BluffInput").visible = false
				player.game_over = true
				player.to_phase_1()
				_start_next_round_after_delay()
			return

		# Only player lied -> player loses
		if player_lied and !enemy_lied:
			player_loses_round("Result: You Lose! Opponent correctly called your bluff.")
			return

		# Only enemy lied -> enemy loses
		if !player_lied and enemy_lied:
			opponent_loses_round("Result: You Win! You correctly called the opponent's bluff.")
			return

		# Both truthful and both called wrongly -> draw
		if !player_lied and !enemy_lied:
			player.get_node("Labels/ResultLabel").text = "Result: Both claims were truthful and both called bluff wrongly! Draw!"
			player.get_node("BluffUI/Control/BluffInput").visible = false
			player.game_over = true
			player.to_phase_1()
			_start_next_round_after_delay()
			return

	
	# CASE 2: ONLY PLAYER called bluff
	if player_calls_bluff and !enemy_calls_bluff:
		if enemy_lied:
			opponent_loses_round("Result: You Win! You correctly called the opponent's bluff.")
			return
		else:
			player_loses_round("Result: You Lose! You called bluff, but the opponent was telling the truth.")
			return


	# CASE 3: ONLY ENEMY called bluff
	if enemy_calls_bluff and !player_calls_bluff:
		if player_lied:
			player_loses_round("Result: You Lose! Opponent correctly called your bluff.")
			return
		else:
			opponent_loses_round("Result: You Win! Opponent called bluff, but you were telling the truth.")
			return

	
	# CASE 4: NOBODY called bluff
	# then laimed totals become official totals
	var official_player_total = claimed_player_total
	var official_enemy_total = enemy_claimed_total

	var winner = get_winner(official_player_total, official_enemy_total)

	if winner == "player":
		opponent_loses_round(
			"Result: You Win! Your official total = " + str(official_player_total) +
			", Opponent official total = " + str(official_enemy_total)
		)
	elif winner == "opponent":
		player_loses_round(
			"Result: You Lose! Your official total = " + str(official_player_total) +
			", Opponent official total = " + str(official_enemy_total)
		)
	else:
		player.get_node("ResultLabel").text = (
			"Result: Draw! Your official total = " + str(official_player_total) +
			", Opponent official total = " + str(official_enemy_total)
		)
		player.get_node("BluffUI/Control/BluffInput").visible = false
		player.game_over = true
		player.to_phase_1()
		_start_next_round_after_delay()


# Player says enemy is bluffing
func player_call_bluff() -> void:
	player_calls_bluff = true
	player_made_showdown_choice = true
	try_resolve_showdown()


# Player accepts enemy claim as truth
func player_pass_bluff() -> void:
	player_calls_bluff = false
	player_made_showdown_choice = true
	try_resolve_showdown()


# Enemy says player is bluffing
func enemy_call_bluff() -> void:
	enemy_calls_bluff = true
	enemy_made_showdown_choice = true
	try_resolve_showdown()


# Enemy accepts player claim as truth
func enemy_pass_bluff() -> void:
	enemy_calls_bluff = false
	enemy_made_showdown_choice = true
	try_resolve_showdown()


# Normal comparison using actual totals only
func resolve_normal_result():
	var winner = get_winner(player_total, enemy_total)

	if winner == "player":
		opponent_loses_round("Result: You Win! Opponent had " + str(enemy_total))
	elif winner == "opponent":
		player_loses_round("Result: You Lose! Opponent had " + str(enemy_total))
	else:
		player.get_node("ResultLabel").text = "Result: Draw! Opponent had " + str(enemy_total)
		player.game_over = true
		player.to_phase_1()
		_start_next_round_after_delay()


# Update life labels on UI
func update_life_labels():
	if player_life_label == null or opponent_life_label == null:
		return

	player_life_label.text = "Player Life: " + str(player.get_life())
	opponent_life_label.text = "Opponent Life: " + str(enemy.life_total)


# Called when enemy loses a round
func opponent_loses_round(message):
	enemy.life_total -= 1
	update_life_labels()

	player.get_node("Labels/ResultLabel").text = message
	player.get_node("BluffUI/Control/BluffInput").visible = false
	player.get_node("MonitorCards").clear_cards()

	if enemy.life_total <= 0:
		player.get_node("Labels/ResultLabel").text = message + " — You win the match!"
		player.game_over = true
		player.to_phase_1()
		show_final_result(true)
		return

	player.game_over = true
	player.to_phase_1()
	_start_next_round_after_delay()


# Called when player loses a round
func player_loses_round(message):
	player.player_life -= 1
	update_life_labels()

	player.get_node("Labels/ResultLabel").text = message
	player.get_node("BluffUI/Control/BluffInput").visible = false
	player.get_node("MonitorCards").clear_cards()

	if player.player_life <= 0:
		player.get_node("Labels/ResultLabel").text = message + " — Game Over! You lose the match."
		player.game_over = true
		player.to_phase_1()
		show_final_result(false)
		return

	player.game_over = true
	player.to_phase_1()
	_start_next_round_after_delay()


# Wait a bit, then reset round and start next one
func _start_next_round_after_delay() -> void:
	await get_tree().create_timer(2.0).timeout

	player_state = State.DRAW
	enemy_state = State.DRAW
	reset_round_flags()

	if enemy != null and enemy.has_method("reset_for_new_round"):
		enemy.reset_for_new_round()

	player.start_round()

	if randf() < 0.5:
		player_turn = Turn.PLAYER
		emit_signal("current_turn", Turn.PLAYER)
	else:
		player_turn = Turn.ENEMY
		emit_signal("current_turn", Turn.ENEMY)

# Final Screen showing according to the result
func show_final_result(player_won: bool):
	var final_result_screen = player.get_node("FinalScreen")
	var final_result_label = player.get_node("FinalScreen/ResultLabel")
	var replay_button = player.get_node("FinalScreen/ReplayButton")
	var next_button = player.get_node("FinalScreen/NextLevelButton")
	
	if player_won:
		final_result_label.text = "YOU WIN"
		replay_button.visible = false
		next_button.visible = true
		next_button.disabled = false
	else:
		final_result_label.text = "ENEMY WIN"
		
		replay_button.visible = true
		next_button.visible = true
		next_button.disabled = true	
		
	final_result_screen.visible = true
		
	player.game_over = true
	
	player.get_node("table").visible = false
	player.get_node("Monitor").visible = false
	player.get_node("BluffUI").visible = false
	player.get_node("ActionButton").visible = false
	player.get_node("ShowdownButtons").visible = false
	player.get_node("Labels").visible = false
	player.get_node("MonitorCards").visible = false
	player.get_node("RestartUI").visible = false
	enemy.get_node("AnimationController").visible = false

func _trigger_draw_powerup() -> void:
	player.draw_powerup = true;
