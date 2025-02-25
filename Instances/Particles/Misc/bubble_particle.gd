extends Node2D

@onready var starting_pos := global_position
var wave := 0.0
func _physics_process(delta: float) -> void:
	wave += 8 * delta
	global_position.y -= 16 * delta
	global_position.x = starting_pos.x + sin(wave) * 2
	if $Area.get_overlapping_areas().any(func(area: Area2D): return area.owner is WaterArea) == false and wave > 1:
		pop()

func pop() -> void:
	$Animation.play("Pop")
