extends Enemy

var falling := false
var can_fall := true

var curious := false

var recovering := true

const CUR_DIST := 64
const FALL_DIST := 48

func _physics_process(delta: float) -> void:
	player = CoopManager.get_closest_player(global_position)
	if player.global_position.y < global_position.y and not falling and not recovering:
		return
	if is_on_ceiling() and recovering:
		falling = false
		recovering = false
		await get_tree().create_timer(1, false).timeout
		can_fall = true
	if player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
	sprite.scale.x = -direction
	var player_distance = abs(player.global_position.x - global_position.x)
	if player_distance <= FALL_DIST:
		fall()
	else:
		curious = player_distance <= CUR_DIST
	
	if falling:
		velocity.y += 15
		if is_on_floor():
			recovering = false
			falling = false
			GameManager.shake_camera(15.0)
			SoundManager.play_sfx(SoundManager.bullet, self)
			await get_tree().create_timer(1, false).timeout
			sprite.play("Idle")
			recovering = true
	elif is_on_ceiling():
		if curious:
			sprite.play("Curious")
		else:
			sprite.play("Idle")
	if recovering:
		velocity.y = -50
	move_and_slide()

func fall() -> void:
	if can_fall:
		can_fall = false
	else:
		return
	falling = true
	sprite.play("Fall")
