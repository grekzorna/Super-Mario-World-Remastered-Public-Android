extends BowserBossState

@export var fly_prog := 1.0
@export var fly_speed := 1.0
@export var h_fly_speed := 16
@export var v_fly_speed := 16
@export var v_fly_mult := 32
@export var h_fly_mult := 128

func enter(_msg:= {}) -> void:
	boss.can_hurt = true
	boss.bowser_sprite.play("Idle")
	boss.attack_timer.stop()
	boss.attack_timer.start(randf_range(5, 10))

func physics_update(delta: float) -> void:
	fly_prog += fly_speed * delta
	fly_prog = wrap(fly_prog, 0, 2 * PI)
	if sin(fly_prog) < 0:
		boss.visuals.scale.x = -1
	else:
		boss.visuals.scale.x = 1
	boss.global_position = boss.screen_center + Vector2(sin(fly_prog) * h_fly_mult, cos(fly_prog * 2) * v_fly_mult)
