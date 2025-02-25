class_name RipVanFish
extends Enemy

var chasing := false

var chase_timer := 0.0

const move_speed := 50
var player_target: Player = null

signal woken_up

func _physics_process(delta: float) -> void:
	if chasing:
		chasing_state(delta)
	else:
		sleeping_state(delta)
	sprite.scale.x = direction
	move_and_slide()

func sleeping_state(delta: float) -> void:
	velocity.y += 5
	velocity.x = 0
	velocity.y = clamp(velocity.y, -99999, 50)
	sprite.play("Sleeping")

func chasing_state(delta: float) -> void:
	sprite.play("Chasing")
	player_target = CoopManager.get_closest_player(global_position)
	var direction_vector := Vector2.ZERO
	if is_instance_valid(player_target):
		direction_vector = (player_target.global_position - global_position).normalized()
		if player_target.is_star:
			direction_vector *= -1
		velocity = lerp(velocity, direction_vector * 75, delta)
		if direction_vector.x > 0:
			direction = -1
		else:
			direction = 1
	chase_timer -= 1 * delta
	if chase_timer <= 0:
		$SleepParticleTimer.start(1)
		chasing = false

func alert() -> void:
	if chasing:
		return
	woken_up.emit()
	chase_timer = 10.0
	chasing = true

func _on_startle_box_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		alert()

const SLEEP_PARTICLE = preload("res://Instances/Particles/Misc/sleep_particle.tscn")
func _on_sleep_particle_timer_timeout() -> void:
	var node = SLEEP_PARTICLE.instantiate()
	node.global_position = global_position - Vector2(0, 16)
	woken_up.connect(node.pop)
	add_sibling(node)
	if not chasing:
		$SleepParticleTimer.start(1)
