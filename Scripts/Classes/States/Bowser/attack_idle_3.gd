extends BowserBossState
var fly_direction := 1

func enter(_msg:= {}) -> void:
	boss.clown_car_eyes.play("Angry")
	boss.can_hurt = true
	boss.bowser_sprite.play("Idle")
	boss.attack_timer.stop()
	boss.attack_timer.start(randf_range(4, 5))

func physics_update(delta: float) -> void:
	var player_target: Player = CoopManager.get_closest_player(boss.global_position)
	if player_target.global_position.x > boss.global_position.x:
		fly_direction = 1
	elif player_target.global_position.x < boss.global_position.x:
		fly_direction = -1
	boss.velocity.y += 10
	if boss.is_on_floor():
		boss.velocity.x = 50 * fly_direction
		boss.velocity.y = -350
		SoundManager.play_sfx(SoundManager.bullet, boss)
	boss.visuals.scale.x = -fly_direction
	if boss.is_on_wall():
		fly_direction *= -1
	boss.move_and_slide()
