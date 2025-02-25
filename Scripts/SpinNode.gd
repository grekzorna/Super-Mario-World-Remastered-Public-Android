@tool
extends Node2D

@export var spin_speed := 100

@export var spin_direction := -1

func _ready() -> void:
	for i in get_children():
		i.rotation = 0

func _physics_process(delta: float) -> void:
	for i in get_children():
		if i is Node2D:
			i.global_position = global_position
			i.rotation_degrees += (spin_speed * spin_direction) * delta
			if i.rotation_degrees > 360 or i.rotation_degrees < -360:
				i.rotation_degrees = 0
