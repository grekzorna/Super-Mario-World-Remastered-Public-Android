extends State

func enter(_msg := {}) -> void:
	owner.can_hurt = false
	await get_tree().create_timer(5, false).timeout
	state_machine.transition_to("Jump")

func physics_update(delta: float) -> void:
	owner.animations.play("Shell")
	var target_player: Player = CoopManager.get_closest_player(owner.global_position)
	var target_direction := 1
	if target_player.global_position.x < owner.global_position.x:
		target_direction = -1
	owner.velocity.x = lerpf(owner.velocity.x, 150 * target_direction, delta * 2)
	owner.move_and_slide()

func exit() -> void:
	owner.velocity = Vector2.ZERO
