extends BowserBossState
const BIG_STEELY = preload("res://Instances/Prefabs/Enemies/big_steely.tscn")
func enter(_msg := {}) -> void:
	boss.can_hurt = false
	boss.bowser_sprite.play("Leave")
	await boss.bowser_sprite.animation_finished
	boss.clown_car_animations.play("Steely")
	await get_tree().create_timer(1, false).timeout
	drop_steely()
	await get_tree().create_timer(0.5, false).timeout
	await boss.clown_car_animations.animation_finished
	boss.bowser_sprite.play("Enter")
	await boss.bowser_sprite.animation_finished
	boss.return_to_attack()

func drop_steely() -> void:
	var node = BIG_STEELY.instantiate()
	var direction := 1
	var target_player = CoopManager.get_closest_player(boss.global_position)
	if target_player.global_position.x < boss.global_position.x:
		direction = -1
	direction = clamp(direction, -1, 1)
	node.global_position = boss.global_position
	node.direction = direction
	boss.add_sibling(node)
	node.direction = direction
	SoundManager.play_sfx(SoundManager.boss_fall, boss)
