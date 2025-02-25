extends Node

@onready var container: VBoxContainer = $UI/Container
@onready var fps: Label = $UI/Container/FPS
@onready var player_state: Label = $UI/Container/PlayerState
@onready var player_power_state: Label = $UI/Container/PlayerPowerState
@onready var player_position: Label = $UI/Container/PlayerPosition
@onready var player_velocity: Label = $UI/Container/PlayerVelocity
@onready var current_held_item: Label = $UI/Container/CurrentHeldItem
@onready var current_level: Label = $UI/Container/CurrentLevel
@onready var player_animations: Label = $UI/Container/PlayerAnimations



@onready var player_info = [player_state, player_power_state, player_position, player_velocity, current_held_item, player_animations]

var debug_visible := false
signal settings_open

func _ready() -> void:
	for i in container.get_children():
		if i is Label:
			i.uppercase = true

func _process(delta: float) -> void:
	container.visible = debug_visible
	
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	handle_player_info()
	current_level.visible = is_instance_valid(GameManager.current_level)
	if is_instance_valid(GameManager.current_level):
		current_level.text = "Current Level: " + str(GameManager.current_level.name)
		
	if Input.is_action_just_pressed("debug_info"):
		debug_visible = !debug_visible
	if Input.is_action_just_pressed("debug_settings"):
		settings_open.emit()

func handle_player_info() -> void:
	for i in player_info:
		i.visible = is_instance_valid(GameManager.player)
	if is_instance_valid(GameManager.player):
		var player: Player = GameManager.player
		player_state.text = "Player State: " + player.state_machine.state.name
		player_power_state.text = "Player Power State: " + player.power_state.state_name
		player_position.text = "Player Position: " + str(player.global_position)
		player_velocity.text = "Player Velocity: " + str(Vector2(int(player.velocity.x), int(player.velocity.y)))
		if player.holding and is_instance_valid(player.held_object):
			current_held_item.text = "Held Item: " + str(player.held_object.name)
		current_held_item.visible = player.holding
		player_animations.text = "Player Animation / Override: " + str(player.current_animation, player.animation_override)
		
