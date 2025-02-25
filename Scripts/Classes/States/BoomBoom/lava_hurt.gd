extends BoomBossClass

var can_hit_wall = true

func enter(_msg := {}) -> void:
	boss.puff_trail.emitting = true
	can_hit_wall = true
	if boss.flying:
		boss.animations.play("WingHurt")
	else:
		boss.animations.play("NormalHurt")
	boss.velocity.x = 150 * boss.direction
	boss.velocity.y = -350

func physics_update(delta: float) -> void:
	boss.velocity.y += 10
	if boss.is_on_wall() and can_hit_wall:
		can_hit_wall = false
		boss.velocity.x = -150 * boss.direction
		boss.direction *= -1
		await get_tree().physics_frame
		can_hit_wall = true
		
	if boss.is_on_floor():
		boss.play_stomp_effect()
		state_machine.transition_to("Hurt")

func exit() -> void:
	boss.puff_trail.emitting = false
