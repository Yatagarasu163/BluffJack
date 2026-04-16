extends Node

@onready var genNumBtn = $Button;
var hasStarted = false;
var callOutChance = 50;
var numbers = [];
var playerBluffVal;


# Chance mechanics
@export var winningVal = 21;
@export var paranoia_value = 3.0;


# Starts a new hand for the AI
func newRound() -> void:
	playerBluffVal = randi_range(1, 21);
	numbers = [];
	for i in range(2):
		drawCard();
	print(numbers);

# Testing purposes
func _on_button_pressed() -> void:
	newRound()
	
	while drawCardDecider():
		drawCard();
	
	print("Final Hand: ", numbers);
	print("Final Total: ", calculateTotal());
	
	var roundDecision = roundDecider();
	print("AI Decision: ", roundDecision);
	
	var real_value = randi_range(1, 45);
	var bluff_value = randi_range(real_value, winningVal);
	
	print("Player Real Value: ", real_value);
	print("Player Bluff Value: ", bluff_value);
	
	print("AI calls bluff?: ", callsBluff(real_value, bluff_value));

# Calculates the total value of the numbers in the AI's hand.
func calculateTotal() -> int:
	var totalInHand = 0;
	
	for number in numbers:
		totalInHand += number;
	return totalInHand;

# Generates a pseudo random number for the AI
func generateNumber() -> int: 
	return randi_range(1, 9);

# Decides what the AI will do for its round
func roundDecider() -> Dictionary:
	var totalInHand = calculateTotal();
	var distance = winningVal - totalInHand;
	var bluff_chance = distance / float(winningVal);
	if(bluff_chance != 0):
		bluff_chance += randf_range(-0.1, 0.1);
		bluff_chance = clamp(bluff_chance, 0.0, 1.0);
	var will_bluff = randf() < bluff_chance;
	
	var shown_value: int
	if will_bluff:
		shown_value = generate_bluff_value(totalInHand);
	else: 
		shown_value = totalInHand;
		
	return {
		"bluffing": will_bluff,
		"value": shown_value
	};
	
# Decides if the AI will draw a card or not
func drawCardDecider() -> bool:
	var currentTotal = calculateTotal();
	var card_count = numbers.size();
	var target = winningVal;
	
	if currentTotal >= target:
		return false;
	
	if card_count >= 5:
		return false;

	var distance = target - currentTotal
	var draw_chance = distance / float(target);
	
	draw_chance = pow(draw_chance, 1.5);
	
	draw_chance += randf_range(-0.05, 0.05);
	draw_chance = clamp(draw_chance, 0.0, 1.0);
	
	return randf() < draw_chance;

# Draws a card for the AI.
func drawCard() -> void:
	numbers.append(generateNumber());

# Determines the value that the AI will use to bluff
func generate_bluff_value(real_value: int) -> int:
	var min_bluff = max(real_value, playerBluffVal) + 1;
	if min_bluff > winningVal: 
		return real_value;
	var gameRange = winningVal - min_bluff;
	var t = pow(randf(), 2.0);
	var bluff = min_bluff + int(gameRange * t);
	return clamp(bluff, min_bluff, winningVal);

# Determines if the AI will call the player's bluff or not
func callsBluff(real_val: int, bluff_val: int) -> bool:
	var lie_size = bluff_val - real_val;
	if abs(lie_size) <= 0:
		return false;
	var proximity = winningVal - bluff_val;
	var closeness = 1.0 / (proximity + 1.0);
	var suspicion = lie_size * closeness;
	var call_chance = clamp(suspicion / paranoia_value, 0.0, 1.0);
	call_chance += randf_range(-0.2, 0.2);
	call_chance = clamp(call_chance, 0.0, 1.0);
	
	if bluff_val >= 19 && bluff_val <= 23:
		call_chance *= 1.3;
		call_chance = clamp(call_chance, 0.0, 1.0);
	
	return randf_range(0, 1) < call_chance;
