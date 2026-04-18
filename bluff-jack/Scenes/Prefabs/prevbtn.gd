extends RichTextLabel

func _ready() -> void:
	text = """
[b]BluffJack Rules:[/b]

Bluffjack is a parodical take on the traditional game, BlackJack.
The goal is to reach 21!

The game is split into 3 phases:
- DRAW phase
- BLUFF phase
- SHOWDOWN phase

However, there are some changes...

[b]1) Bluffing[/b]
a. Players are allowed to bluff. Going above 21 does NOT disqualify you.
b. You can draw up to 5 cards and start with 2 cards.
c. Press "Stay" to enter the bluff phase.
d. Enter your bluff value to lock in your claimed total.
e. In showdown, choose to call out or pass.

[b]2) Resolution[/b]
a. Closest to 21 wins if both are under.
b. Bluff not caught → claimed total is used.
c. Bluff caught → actual total is used.
d. Applies to both players.
e. If both bluff → both use actual totals.
f. If one is caught bluffing → they lose.
g. If a truthful player is called out → caller loses.

[b]3) Power Ups[/b]
a. Enemies become more aggressive or gain advantages.
b. They can:
   - Change your draw
   - Change your hand
   - Change the winning value

[b]4) Winning[/b]
a. Win → progress
b. Lose → ... well, you know.
"""
