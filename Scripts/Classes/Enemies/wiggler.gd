extends Enemy

var angry := false
var wave_prog := 0.0
@onready var parts = [$Head, $Body1, $Body2, $Body3, $Body4]
@onready var collision: CollisionShape2D = $Collision
@onready var bodies = [$Body1, $Body2, $Body3, $Body4]
@onready var floor_check: LedgeDetectionCast = $FloorCheck

var locations = []
var move_speed := 25

var part_position_sep := 16

var frame_index := 0
var can_wall_hit := true
var can_move := true

var dead := false

@onready var wave_test = global_position.y

func _ready() -> void:
	for i in 28 * part_position_sep:
		locations.push_front(Vector2(lerp(global_position.x, global_position.x + (28 * part_position_sep), i / (28 * part_position_sep)), global_position.y))
	for i in parts:
		i.top_level = true

func _physics_process(delta: float) -> void:
	handle_part_waving(delta)
	handle_part_movement(delta)
	handle_base_movement(delta)

func handle_part_waving(delta: float) -> void:
	var wave_rate := 8
	var wave_amp := 1
	var part_index := 0
	if angry:
		wave_rate = 16
	wave_prog -= wave_rate * delta
	for i in parts:
		i.offset.y = (sin(wave_prog + part_index) * wave_amp)
		i.offset.y -= 8
		part_index += 1
	$Head/Flower.offset.y = parts[0].offset.y

func handle_part_movement(delta: float) -> void:
	$Head/Flower.position.x = -2 * direction
	$Head/Flower.scale.x = -direction
	floor_check.position.x = abs(floor_check.position.x) * direction
	floor_check.floor_normal = get_floor_normal()
	var part_index := 0
	if can_move or dead:
		locations.push_front(global_position)
		if locations.size() > (parts.size() - 1) * part_position_sep:
			for i in parts:
				var new_location = locations[(part_index) * part_position_sep]
				var part_direction := 1
				if new_location.x - i.global_position.x > 0:
					part_direction = -1
				i.global_position = new_location
				if not dead:
					i.flip_h = part_direction == -1
				part_index += 1
			locations.pop_back()

func handle_base_movement(delta: float) -> void:
	if (is_on_wall()):
		direction *= -1
	elif $FloorCheck.is_colliding() == false and is_on_floor():
		direction *= -1
	if is_on_floor():
		$FloorCheck.position.x = abs($FloorCheck.position.x) * direction
		$FloorCheck.floor_normal = get_floor_normal()
	if can_move:
		if angry:
			part_position_sep = 4
			velocity.x = (move_speed * 2) * direction
		else:
			velocity.x = move_speed * direction
		velocity.y += 15
	else:
		velocity.x = 0
		velocity.y += 5
		
	move_and_slide()


func _on_animation_timer_timeout() -> void:
	frame_index += 1
	frame_index = wrap(frame_index, 0, 4)
	if dead:
		parts[0].flip_h = not parts[0].flip_h
	var part_index := 0
	for i in bodies:
		if dead:
			i.flip_h = not i.flip_h
		var frame = frame_index - part_index
		frame = wrap(frame, 1, 4)
		i.frame_coords.x = frame
		part_index += 1

func damage() -> void:
	anger()

func die(add_score := false) -> void:
	summon_gib()

func anger() -> void:
	if angry:
		return
	$Head/Flower.hide()
	can_stomp_on = false
	can_move = false
	await get_tree().physics_frame
	can_add_score = false
	for i in parts:
		i.frame_coords.y = 1
		await get_tree().create_timer(0.1, false).timeout
	angry = true
	can_move = true

func summon_gib() -> void:
	if dead:
		return
	dead = true
	can_move = false
	SoundManager.play_sfx(SoundManager.kick, self)
	can_hurt = false
	can_damage = false
	await get_tree().physics_frame
	var part_index := 1
	for i in parts:
		i.get_node("Hitbox").queue_free()
	collision.set_deferred("disabled", true)
	velocity.y = -200
	await get_tree().create_timer(4, false).timeout
	queue_free()


func _on_timer_timeout() -> void:
	if not angry:
		return
	var target_player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
