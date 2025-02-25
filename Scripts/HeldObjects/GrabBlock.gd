class_name GrabBlock
extends HeldObject

const GRAB_BLOCK_IDLE_BREAK = preload("res://Assets/Sprites/Particles/GrabBlockIdleBreak.png")
const BLOCK_BREAK = preload("res://Assets/Sprites/Particles/flashing_block_particle.tres")

var active := false

func _physics_process(delta: float) -> void:
	if player:
		position_direction = 1 if global_position.x > player.global_position.x else -1
	set_collision_layer_value(3, not active and not held)
	velocity_lerp = lerp(velocity_lerp, velocity, delta * 10)
	velocity.y += gravity
	velocity.y = clamp(velocity.y, -999, 275)
	moving = active and abs(velocity.x) > 10
	if is_on_floor() and not held and velocity.y > 0 and abs(velocity.x) < 100:
		velocity.x = lerpf(velocity.x, 0, delta * 10)
	if is_on_wall() and not held and active:
		die()
	physics_update(delta)
	if active:
		move_and_slide()
	check_for_collisions()

func die() -> void:
	if active:
		ParticleManager.summon_four_part([BLOCK_BREAK, BLOCK_BREAK, BLOCK_BREAK, BLOCK_BREAK], global_position - Vector2(0, 8))
	else:
		ParticleManager.summon_four_part([GRAB_BLOCK_IDLE_BREAK, GRAB_BLOCK_IDLE_BREAK, GRAB_BLOCK_IDLE_BREAK, GRAB_BLOCK_IDLE_BREAK], global_position - Vector2(0, 8))
	SoundManager.play_sfx(SoundManager.shatter, self)
	queue_free()

func _process(delta: float) -> void:
	#print(moving)
	if player_can_stand:
		set_collision_layer_value(1, not held and not active)
	if press_pickup and hitbox.get_overlapping_areas().any(is_player):
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id)):
			player.pickup_object(self)
	update(delta)

func on_kick() -> void:
	activate()

func kick_forward() -> void:
	on_kick()
	velocity.y = 0
	var dir = direction
	if is_instance_valid(player):
		if player.input_direction != 0:
			dir = player.input_direction
		else:
			dir = player.direction
	velocity.x = 250 * dir
	if kick_bounce:
		velocity.y = -100

func activate() -> void:
	active = true
	press_pickup = false
	$Sprite.play("Active")
	for i in 2:
		await get_tree().physics_frame
	destructable = true
	await get_tree().create_timer(8.5, false).timeout
	die()
