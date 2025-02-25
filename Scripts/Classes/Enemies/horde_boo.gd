extends Enemy

@onready var starting_position := global_position

var idle_wave := 0.0

var idle := true
var swooping := false

var chosen_number := 0

func _ready() -> void:
	randomize()
	chosen_number = randi_range(0, 50)
	idle_wave = randf_range(0, PI * 2)
	$Sprite.play(["1", "2", "3"].pick_random())
	$Timer.start()
	global_position.x = starting_position.x + sin(idle_wave) * 48
	global_position.y = starting_position.y + cos(idle_wave * 4) * 4
	await get_tree().physics_frame
	add_child(VisibleOnScreenEnabler2D.new())

var swoop_direction := 1

var swoop_wave := 0.0

func _physics_process(delta: float) -> void:
	sprite.scale.x = direction
	if idle:
		handle_idle_state(delta)
	elif swooping:
		handle_swoop(delta)
	else:
		$Sprite.modulate.a = lerpf($Sprite.modulate.a, 1, delta * 5)



func handle_idle_state(delta: float) -> void:
	$Sprite.modulate.a = lerp($Sprite.modulate.a, 0.3, delta * 5)
	idle_wave += 1 * delta
	if starting_position.x + sin(idle_wave) * 48 > global_position.x:
		direction = 1
	else:
		direction = -1
	global_position.x = starting_position.x + sin(idle_wave) * 48
	global_position.y = starting_position.y + cos(idle_wave * 4) * 4

func handle_swoop(delta: float) -> void:
	direction = swoop_direction
	swoop_wave += 1.2 * delta
	global_position.y = starting_position.y + (sin(swoop_wave) * 128)
	global_position.x += 1 * swoop_direction
	if swoop_wave >= PI:
		$Hitbox.set_deferred("monitorable", false)
		swooping = false
		idle = true
		starting_position = global_position
		idle_wave = 0

func _on_timer_timeout() -> void:
	if idle == false or randi_range(0, 50) != chosen_number:
		return
	var target_player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.x > global_position.x:
		swoop_direction = 1
	else:
		swoop_direction = -1
	idle = false
	swoop_wave = 0
	await get_tree().create_timer(1, false).timeout
	$Hitbox.set_deferred("monitorable", true)
	starting_position = global_position
	swooping = true
