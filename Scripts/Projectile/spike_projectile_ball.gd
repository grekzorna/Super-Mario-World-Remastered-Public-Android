class_name SpikeBallProjectile
extends Enemy

const parts = preload("res://Assets/Sprites/Particles/SpikeBallDestruction.png")

func _physics_process(delta: float) -> void:
	sprite.global_rotation_degrees += (velocity.x / 8)
	velocity.y += 15
	velocity.x += get_floor_normal().x * 4
	velocity.y = clamp(velocity.y, -99999, 280)
	if is_on_wall() or is_on_ceiling():
		die()
	move_and_slide()

func summon_gib() -> void:
	ParticleManager.summon_four_part([parts, parts, parts, parts], global_position, 8)


func _on_hitbox_area_entered(area: Area2D) -> void:
	var node = area.owner
	if node is Enemy:
		if node.can_held_item_damage:
			node.die()
		else:
			die()
	elif node is SpikeBallProjectile:
		die()
	elif node is HeldObject:
		if node.destructable:
			node.die()
