extends CharacterBody2D

signal collected

var can_bounce := false

func _physics_process(delta: float) -> void:
	velocity.y += 15
	velocity.y = clamp(velocity.y, -999, 280)
	velocity.x = lerpf(velocity.x, 0, delta)
	if is_on_floor():
		$Collision.queue_free()
		velocity.x = 0
		velocity.y = -200
	move_and_slide()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		collect()

func collect() -> void:
	ParticleManager.summon_particle(ParticleManager.SPARKLE, global_position)
	SoundManager.play_sfx(SoundManager.coin, self)
	GameManager.coins += 1
	GameManager.add_score(100, true, global_position)
	collected.emit()
	queue_free()
