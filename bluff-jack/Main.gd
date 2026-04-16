extends Node2D

#Life Counter
var player_life = 3
var opponent_life = 3

var actual_total = 0
var claimed_total = 0
var opponent_total = 0
var game_over = false
var cards = []
var is_player_turn = false;
@onready var bluff_buttons = $Bluff;
@onready var draw_buttons = $Draw;

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
	draw_cards();
	
	print(cards);
	
	#$ActualTotalLabel.text = "Actual Total: 0"
	#$ClaimedTotalLabel.text = "Claimed Total: -"
	#$ResultLabel.text = "Result:"
	#$OpponentActionLabel.text = "Opponent:"

	to_phase_1();
	
# Drawing the card
func _on_draw_card_button_pressed():
	draw_cards();
	actual_total = calculate_total();
	
	$ActualTotalLabel.text = "Actual Total: " + str(actual_total)
	
func draw_cards() -> void:
	if game_over:
		return;
	
	if cards.size() < 2:
		for i in range(2):
			var card = randi_range(1, 9);
			cards.append(card);
		print(cards);
		return;
	
	if cards.size() < 5:
		var card = randi_range(1, 9);
		cards.append(card);
		print(cards);
		return
	

func calculate_total() -> int:
	var total = 0;
	for card in cards:
		total += card;
	return total;
	
# To have actual number without bluffing
func _on_stay_button_pressed():
	to_phase_2();
	if game_over:
		return

	claimed_total = actual_total
	$ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)
	resolve_opponent_decision()
	
func to_phase_2() -> void:
	bluff_buttons.visible = true;
	bluff_buttons.get_child(1).text = "";
	draw_buttons.visible = false;

func to_phase_1() -> void:
	draw_buttons.visible = true;
	bluff_buttons.visible = false;

# Bluffing mechanic activates
func _on_bluff_button_pressed():
	if game_over:
		return

	$OpponentActionLabel.text = "Opponent: Enter bluff number and press Enter"

func _on_bluff_input_text_submitted(new_text):
	if game_over:
		return

	if new_text.is_valid_int():
		claimed_total = int(new_text)
		$ClaimedTotalLabel.text = "Claimed Total: " + str(claimed_total)
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
		to_phase_1();
	

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
	
	if player_life <= 0:
		$ResultLabel.text = message + " Game Over! You lose the match."
	
	game_over = true
	to_phase_1();
		
# If the opponent loses the round
func opponent_loses_round(message):
	opponent_life -= 1
	update_life_labels()
	$ResultLabel.text = message
	
	if opponent_life <= 0:
		$ResultLabel.text = message + " You win " 
	
	game_over = true
	to_phase_1();
	
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
	$DrawCardButton.disabled = not enabled
	$StayButton.disabled = not enabled
	$BluffButton.disabled = not enabled
	$BluffInput.editable = enabled
