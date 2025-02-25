class_name PhysicsCoin
extends CharacterBody2D

var silver := false

var auto_collect := false

var player: Player = null

var can_launch := true

var can_bounce := false

func _ready() -> void:
	if silver:
		$Sprite.play("Silver")
	else:
		ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position - Vector2(0, 8))
	if can_launch:
		velocity = Vector2(50 * [1, -1].pick_random(), -50)
	if auto_collect:
		await get_tree().create_timer(0.5, false).timeout
		collect()

func _physics_process(delta: float) -> void:
	velocity.y += 5
	if is_on_floor():
		velocity.x = lerpf(velocity.x, 0, delta * 3)
		if can_bounce:
			velocity.y = -100
			can_bounce = false
	move_and_slide()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		collect()

func collect() -> void:
	GameManager.add_coin(1)
	GameManager.add_score(100, false)
	if player != null:
		player.play_sfx("coin")
	else:
		SoundManager.play_sfx(SoundManager.coin, self)
	ParticleManager.summon_particle(ParticleManager.SPARKLE, global_position)
	queue_free()
