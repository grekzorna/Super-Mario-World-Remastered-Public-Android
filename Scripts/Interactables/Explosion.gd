class_name Explosion
extends Node2D

func _ready() -> void:
	SoundManager.play_sfx(SoundManager.thunder, self)
	SoundManager.play_sfx(SoundManager.bullet, self)
	ParticleManager.summon_particle(ParticleManager.SPIN_IMPACT, global_position - Vector2(0, 8))
	await get_tree().create_timer(1, false).timeout
	queue_free()



func _on_hitbox_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if node is Player:
		node.damage()
	elif node is BobOmb:
		node.explode()
	elif node is Enemy:
		node.die()
	elif node is SpinBlock:
		node.shatter()
	elif node is HeldObject:
		if node.destructable:
			node.die()
