extends BowserBossState

@export var fly_prog := 1.0
@export var fly_speed := 8
@export var v_fly_mult := 16

var fly_direction := 1

func enter(_msg:= {}) -> void:
	boss.can_hurt = true
	boss.bowser_sprite.play("Idle")
	boss.attack_timer.stop()
	boss.attack_timer.start(randf_range(4, 7))

func physics_update(delta: float) -> void:
	var player_target: Player = CoopManager.get_closest_player(boss.global_position)
	fly_prog += fly_speed * delta
	fly_prog = wrap(fly_prog, 0, 2 * PI)
	boss.global_position.y = boss.screen_center.y + sin(fly_prog) * v_fly_mult 
	if player_target.global_position.x > boss.global_position.x:
		fly_direction = 1
	elif player_target.global_position.x < boss.global_position.x:
		fly_direction = -1
	boss.visuals.scale.x = -fly_direction
	boss.velocity.x = lerpf(boss.velocity.x, 150 * fly_direction, delta * 2)
	boss.move_and_slide()
