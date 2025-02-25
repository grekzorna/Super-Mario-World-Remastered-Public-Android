extends BoomBossClass
@onready var edge_check: RayCast2D = $"../../Sprite/EdgeCheck"
@onready var edge_check_2: RayCast2D = $"../../Sprite/EdgeCheck2"


var target_player: Player = null
var velocity_direction := 1
func enter(_msg := {}) -> void:
	boss.animations.play("Run")
	boss.swing_sfx.play()
	await get_tree().create_timer(randi_range(2, 4), false).timeout
	if boss.states.state == self:
		state_machine.transition_to("Jump")
	

func physics_update(delta: float) -> void:
	target_player = CoopManager.get_closest_player(boss.global_position)
	if target_player.global_position.x > boss.global_position.x:
		boss.direction = 1
	else:
		boss.direction = -1
	if (boss.velocity.x) > 0:
		velocity_direction = 1
	else:
		velocity_direction = -1
	boss.skid_particles.emitting = velocity_direction != boss.direction
	boss.velocity.y += 15
	boss.velocity.x = lerpf(boss.velocity.x, boss.run_speed * boss.direction, boss.run_accel * delta)
	if (edge_check.is_colliding() == false or edge_check_2.is_colliding() == false) and boss.is_on_floor():
		state_machine.transition_to("Jump")

func exit() -> void:
	boss.swing_sfx.stop()
	boss.skid_particles.emitting = false
