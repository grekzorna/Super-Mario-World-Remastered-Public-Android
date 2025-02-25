extends Node2D
const SUMO_BRO_FIRE = preload("res://Instances/Prefabs/Enemies/sumo_bro_fire.tscn")

func _physics_process(delta: float) -> void:
	global_position.y += 128 * delta
	if $RayCast2D.is_colliding():
		summon_fire($RayCast2D.get_collision_point())
		queue_free()

func summon_fire(fire_position := Vector2.ZERO) -> void:
	var node = SUMO_BRO_FIRE.instantiate()
	node.global_position = fire_position
	ParticleManager.summon_particle(ParticleManager.PUFF, fire_position - Vector2(0, 8))
	add_sibling(node) 
