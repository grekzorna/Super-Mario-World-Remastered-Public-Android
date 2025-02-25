class_name Climbable
extends Area2D

@export var punchable := false
@export var lock_x_axis := false
@export var moving := false

var climbable_velocity := global_position

signal player_climbed

var player: Player = null

var translation := Vector2.ZERO
var last_pos := Vector2.ZERO

func _ready() -> void:
	area_exited.connect(_on_area_exited)

func _physics_process(delta: float) -> void:
	translation = (global_position - last_pos)
	for i in get_overlapping_areas():
		if i.get_parent() is Player:
			player = i.get_parent()
			if Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
				player_climbed.emit()
			player.climb_area_velocity = climbable_velocity
			player.climb_x_position = global_position.x
			player.climb_x_lock = lock_x_axis
			player.climb_punch = punchable
			if moving:
				if player.state_machine.state.name == "Climb":
					player.global_position.y += translation.y
	last_pos = global_position

func is_player(area: Area2D) -> bool:
	if area.get_parent() is Player:
		player = area.get_parent()
	return area.get_parent() is Player

func _on_area_exited(area: Area2D) -> void:
	if area.owner is Player:
		player = null
		area.owner.climb_x_lock = false
		if get_parent() is FlipPanel == false:
			area.owner.z_index = 0
