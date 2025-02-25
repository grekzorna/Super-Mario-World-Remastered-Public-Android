# Boilerplate class to get full autocompletion and type checks for the `player` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name PlayerState
extends State

# Typed reference to the player node.
var player: Player
@export var power_state := false
@export var can_change := true
@export var state_name := "State"

func _ready() -> void:
	state_machine = get_parent()
	player = state_machine.get_parent()
	
