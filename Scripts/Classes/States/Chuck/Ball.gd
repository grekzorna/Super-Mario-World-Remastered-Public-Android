extends ChuckState
const CHUCK_BALL = preload("res://Instances/Prefabs/Projectiles/chuck_ball.tscn")

func enter(_msg := {}) -> void:
	await get_tree().physics_frame
	loop()

func physics_update(delta: float) -> void:
	chuck.velocity.y += 10
	if sign(chuck.player.global_position.x - chuck.global_position.x) != chuck.direction:
		state_machine.transition_to("Turn", {"Direction": sign(chuck.player.global_position.x - chuck.global_position.x)})

func loop() -> void:
	for i in chuck.ball_throw_amount - 1:
		await ground_throw()
		await get_tree().create_timer(1, false).timeout
		if state_machine.state != self:
			return
	await jump_throw()
	await get_tree().create_timer(1, false).timeout
	if state_machine.state != self:
		return
	loop()

func ground_throw() -> void:
	chuck.animations.play("BallThrowGround")
	await chuck.animations.animation_finished
	return

func jump_throw() -> void:
	chuck.animations.play("BallThrowAir")
	await get_tree().create_timer(1, false).timeout
	chuck.animations.play("BallIdle")
	return

func throw_ball() -> void:
	var node = CHUCK_BALL.instantiate()
	node.global_position = chuck.global_position + Vector2(9 * chuck.direction, -12)
	node.direction = chuck.direction
	GameManager.current_level.add_child(node)

func jump() -> void:
	chuck.velocity.y = -150
