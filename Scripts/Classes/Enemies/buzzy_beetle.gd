extends Enemy

var can_hit := true
const BUZZY_BEETLE_SHELL = ("res://Instances/Prefabs/HeldObjects/buzzy_beetle_shell.tscn")
var para_red_move := 0.0


func damage() -> void:
	player_bounce()
	SoundManager.play_sfx(SoundManager.kick, self)
	spawn_shell()
	queue_free()

func spawn_shell(flipped := false) -> void:
	var node = load(BUZZY_BEETLE_SHELL).instantiate()
	node.global_position = global_position + Vector2(0, 0)
	get_parent().add_child(node)
	if flipped:
		node.flipped = true
		node.velocity.y = -200
		node.moving = false
		node.velocity.x = 50

func melee_attack() -> void:
	spawn_shell(true)
	SoundManager.play_sfx(SoundManager.kick, self)
	queue_free()

func _physics_process(delta: float) -> void:
	sprite.scale.x = -direction
	velocity.x = 30 * direction
	velocity.y += 10
	if is_on_wall() && can_hit:
		flip_direction()
	else:
		move_and_slide()

func flip_direction() -> void:
	can_hit = false
	direction *= -1
	await get_tree().create_timer(0.1, false).timeout
	can_hit = true
