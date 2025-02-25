class_name WaterBouyancy
extends Node

@export var hitbox: Area2D

@export var max_water_fall := 100
@export var max_water_speed := 50

func is_in_water() -> bool:
	return hitbox.get_overlapping_areas().any(is_water)

func _physics_process(delta: float) -> void:
	if owner is CharacterBody2D:
		if is_instance_valid(hitbox):
			if hitbox.get_overlapping_areas().any(is_water):
				owner.velocity.y = clamp(owner.velocity.y, -888, max_water_fall)
				owner.velocity.x = clamp(owner.velocity.x, -max_water_speed, max_water_speed)

func is_water(area: Area2D) -> bool:
	return area.owner is WaterArea
