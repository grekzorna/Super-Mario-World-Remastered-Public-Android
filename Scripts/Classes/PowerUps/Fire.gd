extends PowerScript

var fire_attack := false
const FIREBALL = preload("res://Instances/Prefabs/Projectiles/fireball.tscn")
var throw_direction := 1

var fireball_amount := 0

var spin_fire_meter := 1.0

func _physics_process(delta: float) -> void:
	match player.state_machine.state.name:
		"Normal":
			main(delta)
		"Swim":
			main(delta)
		_:
			pass

func main(delta: float) -> void:
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id)) and not player.spinning and not player.riding_yoshi and not player.crouching:
		throw_fire_ball(player.direction)
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)) and player.is_on_floor() and not player.crouching:
		spin_fire_meter = 1
		throw_direction = player.direction
	if player.spin_jumping and spin_fire_meter >= 1:
		spin_fire_meter = 0
		throw_fire_ball(throw_direction)
		throw_direction *= -1
	spin_fire_meter += 4 * delta
	spin_fire_meter = clamp(spin_fire_meter, 0, 1)

func throw_fire_ball(direction := 1) -> void:
	if fireball_amount >= 2:
		return
	if player.holding or player.carrying:
		return
	fire_ball(direction)
	if not player.sprite.animation == "Spin":
		if player.is_on_floor():
			player.animation_override = "Attack"
		else:
			player.animation_override = "SwimIdle"
	await get_tree().create_timer(0.1).timeout
	player.animation_override = ""



func fire_ball(throw_direction := 1) -> void:
	player.play_sfx("fireball")
	fireball_amount += 1
	var fire_ball_node = FIREBALL.instantiate()
	fire_ball_node.global_position = player.global_position - Vector2(0, 16)
	fire_ball_node.direction = throw_direction
	fire_ball_node.player = player
	fire_ball_node.z_index = player.z_index
	fire_ball_node.tree_exited.connect(fire_ball_exited)
	fire_ball_node.velocity.x = player.velocity.x
	GameManager.current_level.add_child(fire_ball_node)

func fire_ball_exited() -> void:
	fireball_amount -= 1
	fireball_amount = clamp(fireball_amount, 0, 3)
