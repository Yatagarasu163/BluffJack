extends Node2D

#Life Counter
var player_life = 3
var opponent_life = 3

var actual_total = 0
var claimed_total = 0
var opponent_total = 0
var game_over = false
var cards = []

# starting the game
func _ready():
	randomize()
	start_match()

#Starting the Match
func  start_match():
	player_life = 3
	opponent_life = 3
	update_life_labels()
	start_round()
	
# Restarting the round
func start_round():
	cards = []
	actual_total = 0
	claimed_total = 0
	opponent_total = randi_range(15, 25)
	game_over = false
	
	$MonitorCards.clear_cards()

	$ActualTotalLabel.text = "Actual Total: 0"
	$ClaimedTotalLabel.text = "Claimed Total: -"
	$ResultLabel.text = "Result:"
	$OpponentActionLabel.text = "Opponent:"
	$BluffUI/Control/BluffInput.visible = false
	$BluffUI/Control/BluffInput.text = ""
	$BluffUI/Control/BluffInput.placeholder_text = "Enter Bluff Number"
	
	
	set_buttons_enabled(true)
# Drawing the card
func _on_draw_card_button_pressed():
	if game_over:
		return
	
	if cards.size() >= 5:
		$ResultLabel.text = "Result: Max 5 cards drawn"
		return
		
	var card = randi_range(1, 9)
	cards.append(card)
	$MonitorCards.show_card(card)


	actual_total = 0
	for i in cards:
		actual_total += i
	
	$ActualTotalLabel.text = "Actual Total: " + str(actual_total)

# To have actual number without bluffing
func _on_stay_button_pressed():
	if game_over:
		return

	claimed_total = actual_total
	$ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)
	resolve_opponent_decision()

# Bluffing mechanic activates
func _on_bluff_button_pressed():
	if game_over:
		return

	$OpponentActionLabel.text = "Opponent: Enter bluff number and press Enter"
	
	$BluffUI/Control/BluffInput.visible = true
	$BluffUI/Control/BluffInput.text = ""
	$BluffUI/Control/BluffInput.grab_focus()
	
func _on_bluff_input_text_submitted(new_text):
	if game_over:
		return

	if new_text.is_valid_int():
		claimed_total = int(new_text)
		$ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)
		$BluffUI/Control/BluffInput.visible = false
		$BluffUI/Control/BluffInput.text = ""
		resolve_opponent_decision()

# Opponents decision
func resolve_opponent_decision():
	var calls_bluff = randi() % 2 == 0

	if calls_bluff:
		$OpponentActionLabel.text = "Opponent called bluff!"

		if claimed_total != actual_total:
			player_loses_round("Result: You Lose! Bluff caught.")
		else:
			opponent_loses_round("Result: You Win! Opponent called bluff wrongly.")
	else:
		$OpponentActionLabel.text = "Opponent accepted your claim."
		resolve_normal_result()

# Normal Result without bluffing 
func resolve_normal_result():
	var winner = get_winner(claimed_total, opponent_total)

	if winner == "player":
		opponent_loses_round("Result: You Win! Opponent had " + str(opponent_total))
	elif winner == "opponent":
		player_loses_round("Result: You Lose! Opponent had " + str(opponent_total))
	else:
		$ResultLabel.text = "Result: Draw! Opponent had " + str(opponent_total)
		game_over = true
		set_buttons_enabled(false)
	

#Winning Logic
func get_winner(player_total, enemy_total):
	if player_total == 21 and enemy_total != 21:
		return "player"
	elif enemy_total == 21 and player_total != 21:
		return "opponent"
	elif player_total == 21 and enemy_total == 21:
		return "draw"

	if player_total <= 21 and enemy_total > 21:
		return "player"
	elif enemy_total <= 21 and player_total > 21:
		return "opponent"

	if player_total <= 21 and enemy_total <= 21:
		if player_total > enemy_total:
			return "player"
		elif enemy_total > player_total:
			return "opponent"
		else:
			return "draw"

	if player_total > 21 and enemy_total > 21:
		var player_diff = player_total - 21
		var enemy_diff = enemy_total - 21

		if player_diff < enemy_diff:
			return "player"
		elif enemy_diff < player_diff:
			return "opponent"
		else:
			return "draw"

	return "draw"

# When Player Loses the round 
func player_loses_round(message):
	player_life -= 1
	update_life_labels()
	$ResultLabel.text = message
	$BluffUI/Control/BluffInput.visible = false
	
	$MonitorCards.clear_cards()
	
	if player_life <= 0:
		$ResultLabel.text = message + " Game Over! You lose the match."
	
	game_over = true
	set_buttons_enabled(false)
		
# If the opponent loses the round
func opponent_loses_round(message):
	opponent_life -= 1
	update_life_labels()
	$ResultLabel.text = message
	$BluffUI/Control/BluffInput.visible = false
	
	$MonitorCards.clear_cards()
	
	if opponent_life <= 0:
		$ResultLabel.text = message + " You win " 
	
	game_over = true
	set_buttons_enabled(false)
	
#Updating Life labels
func update_life_labels():
	$PlayerLifeLabel.text ="Player Life: " + str(player_life)
	$OpponentLifeLabel.text ="Opponent Life: " + str(opponent_life)

# Restart Game
func _on_restart_button_pressed():
	if player_life <= 0 or opponent_life <= 0:
		start_match()
	else:
		start_round()
	

func set_buttons_enabled(enabled):
	$ActionButton/DrawCardButton.disabled = not enabled
	$ActionButton/StayButton.disabled = not enabled
	$BluffUI/BluffButton.disabled = not enabled
	$BluffUI/Control/BluffInput.editable = enabled
