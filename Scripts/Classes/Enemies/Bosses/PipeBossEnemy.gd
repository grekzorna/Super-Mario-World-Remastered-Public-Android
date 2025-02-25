extends Enemy

var can_fall := false

var in_lava := false



func damage() -> void:
	if get_node("Sprite").animation != "Hurt":
		can_hurt = false
		can_damage = false
		get_node("Sprite").play("Hurt")
		get_parent().enemy_hit(name)

func _physics_process(delta: float) -> void:
	if can_fall:
		if in_lava:
			velocity.y += 1
		else: velocity.y += 10
		move_and_slide()

func boss_die() -> void:
	SoundManager.play_sfx(SoundManager.boss_fall, self)
	can_fall = true
	get_parent().boss_dead = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is LavaArea:
		velocity.y = 0
		in_lava = true
		get_parent().lava_entered()
