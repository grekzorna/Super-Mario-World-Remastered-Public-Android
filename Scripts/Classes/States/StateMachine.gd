# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

# Emitted when transitioning to a new state.
signal transitioned(state_name)

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state := NodePath()

# The current active state. At the start of the game, we get the `initial_state`.
@onready var state: State = get_node(initial_state)


func _ready() -> void:
	await owner.ready
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.state_machine = self
	state.enter()


# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(state):
		state.handle_input(event)


func _process(delta: float) -> void:
	if is_instance_valid(state):
		state.update(delta)


func _physics_process(delta: float) -> void:
	if is_instance_valid(state):
		state.physics_update(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(target_state_name):
		print("Cannot Find: " + target_state_name)
		return

	state.exit()
	state = get_node(target_state_name)
	if is_instance_valid(state) == false:
		state = get_node(initial_state)
	state.enter(msg)
	emit_signal("transitioned", state.name)

func add_state(state_to_add: Script, state_name := "NewState") -> void:
	var new_state = State.new()
	new_state.script = state_to_add
	add_child(new_state)
	new_state.state_machine = self
	new_state.name = state_name
	get_parent().ready.emit()
