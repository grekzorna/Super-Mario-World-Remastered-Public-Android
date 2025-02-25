extends Node2D

var player: Player = null
@onready var platform: AnimatableBody2D = $Platform

var spinning := false
@onready var rotation_point: Node2D = $Rotation
@onready var hitbox: Area2D = $Platform/Hitbox

var spin_amount := 0.0
var spin_direction := 1
var spin_speed := 0.0



@onready var starting_position = platform.position

func _physics_process(delta: float) -> void:
	spinning = hitbox.get_overlapping_areas().any(is_player)
	
	if spinning:
		if rotation_point.global_rotation_degrees >= -4:
			spin_speed += 1 * delta
		else:
			spin_speed -= 1 * delta
	else:
		spin_speed = move_toward(spin_speed, 0, 0.5 * delta)
	
	rotation_point.global_rotation_degrees += spin_speed

func is_player(area: Area2D) -> bool:
	if area.owner is Player:
		return area.owner.is_on_floor()
	else:
		return false


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	rotation_point.global_rotation_degrees = 0
