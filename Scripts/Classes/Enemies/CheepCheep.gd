extends Enemy

@export_enum("Horizontal", "Vertical") var swim_direction := "Horizontal"

var swim := 0.0

var in_water := false

var current_direction := 1

func _physics_process(delta: float) -> void:
	var last = in_water
	in_water = $Hitbox.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is WaterArea)
	if in_water == false:
		if last != in_water:
			velocity.y = -200
	kickable = not in_water
	if in_water:
		handle_swimming(delta)
	else:
		handle_flopping(delta)
	sprite.scale.x = (direction * current_direction)

func handle_flopping(delta: float) -> void:
	sprite.play("Flop")
	velocity.y += 15
	velocity.x = 50 * direction
	if is_on_floor():
		velocity.y = -100
		direction = [1, -1].pick_random()
	move_and_slide()

func handle_swimming(delta: float) -> void:
	sprite.play("Swim")
	swim += 1 * delta
	velocity = Vector2.ZERO
	move_and_slide()
	var val = sin(swim)
	if is_on_wall():
		current_direction *= -1
	if val > 0:
		direction = 1
	else:
		direction = -1
	global_position.x += (32 * (direction * current_direction) * delta)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		var player: Player = area.get_parent() as Player
		if player.attacking:
			die()
		else:
			player.damage()
	if area.get_parent() is Fireball:
		area.get_parent().queue_free()
		die()
