# Boilerplate class to get full autocompletion and type checks for the `player` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name BowserBossState
extends State

# Typed reference to the player node.
var boss: BowserBoss

func _ready() -> void:
	state_machine = get_parent()
	boss = state_machine.get_parent()
	

