class_name ShelllessKoopa
extends Enemy

@export_enum("Red", "Green", "Yellow", "Purple", "Cyan", "White") var colour := 0
@onready var animations: AnimationPlayer = $Sprite/Animations

const move_speed := 50
const acceleration := 2

@onready var slope_direction = round(get_floor_normal().x)
var troopa_scene: PackedScene = null
@onready var floor_check: RayCast2D = $FloorCheck
const FLASHING_SHELL = preload("res://Instances/Prefabs/Enemies/flashing_shell.tscn")
var sliding := false

var shell_to_kick: Shell = null
@onready var skid: GPUParticles2D = $Skid

var dead := false

var can_kick := true

var can_enter := false

var entering_shell: Shell = null

var velocity_direction := 1

var can_hit := true

var kicking := false

var shell_sliding := false

var slide_timer := 3.0

func _ready() -> void:
	update_texture(get_sprite())
	await get_tree().create_timer(0.25, false).timeout
	can_enter = true
	slide_timer = 3.0


func _physics_process(delta: float) -> void:
	slope_direction = round(get_floor_normal().x)
	floor_check.position.x = abs(floor_check.position.x) * direction
	floor_check.floor_normal = get_floor_normal()
	if not dead:
		if sliding:
			handle_sliding(delta)
		elif kicking:
			handle_kicking(delta)
		else:
			handle_walking(delta)
	else:
		velocity.x = 0
	if velocity.x > 0:
		velocity_direction = 1
	else:
		velocity_direction = -1
	velocity.y += 15
	if colour == 3:
		if is_instance_valid(shell_to_kick):
			shell_to_kick.moving = false
			shell_to_kick.velocity.x = 0
			shell_to_kick.global_position.x = global_position.x + (17 * direction)
	move_and_slide()
	
	
func handle_walking(_delta: float) -> void:
	skid.emitting = false
	shell_sliding = false
	if colour == 3:
		animations.play("SpecialWalk")
	else:
		animations.play("Walk")
	if abs(get_floor_normal().x) >= 0.5:
		sliding = true
		return
	if is_on_wall() and can_hit:
		flip_direction()
	if floor_check.is_colliding() == false and is_on_floor():
		if (colour == 0 or colour == 3) and can_hit:
			flip_direction()
	if is_on_floor():
		velocity.x = move_speed * direction

func flip_direction() -> void:
	can_hit = false
	direction *= -1
	await get_tree().create_timer(0.1, false).timeout
	can_hit = true

func handle_sliding(delta: float) -> void:
	skid.emitting = abs(velocity.x) >= 20
	if kickable:
		animations.play("SlideIdle")
	elif shell_sliding:
		animations.play("ShellExit")
	else:
		animations.play("Slide")
	if get_floor_normal().x != 0:
		velocity.x += (250 * delta) * slope_direction
	else:
		velocity.x = lerpf(velocity.x, 0, delta * 2)
	if get_floor_normal().x > 0:
		slope_direction = 1
	else:
		slope_direction = -1
	velocity.x = clamp(velocity.x, -move_speed * 5, move_speed * 5)
	direction = velocity_direction
	if (get_floor_normal().x > 0 and direction == -1) or (get_floor_normal().x < 0 and direction == 1):
		velocity.y = -abs(velocity.x)
	if abs(velocity.x) <= 20 and get_floor_normal().x == 0:
		slide_timer -= 1 * delta
		kickable = true
		animations.play("SlideIdle")
		if slide_timer <= 0 or colour == 3:
			kickable = false
			velocity.y = -100
			sliding = false
			return

func handle_kicking(delta: float) -> void:
	velocity.x = lerpf(velocity.x, 0, delta * 5)
	animations.stop()
	floor_check.position.x *= -1
	if floor_check.is_colliding() == false:
		velocity.x = 0
	skid.emitting = shell_to_kick != null
	if is_instance_valid(shell_to_kick):
		shell_to_kick.shell_moving = false
		if abs(velocity.x) < 5:
			if can_kick:
				can_kick = false
				await get_tree().create_timer(0.5, false).timeout
				shell_kick()
	else:
		kicking = false
		

func _process(_delta: float) -> void:
	sprite.scale.x = -direction

func damage_player(player_to_damage: Player) -> void:
	if dead:
		return
	player_to_damage.damage()

func get_sprite() -> Texture2D:
	var sprites = [preload("res://Assets/Sprites/Enemys/Koopas/Shell-less Koopa/Red.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/Shell-less Koopa/Green.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/Shell-less Koopa/Yellow.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/Shell-less Koopa/Blue.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/Shell-less Koopa/Cyan.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/Shell-less Koopa/Grey.png")]
	return sprites[colour]

func update_texture(texture: Texture):
	sprite.texture = texture

func damage() -> void:
	dead = true
	$Hitbox.queue_free()
	can_hurt = false
	animations.play("Die")
	await get_tree().create_timer(0.5, false).timeout
	queue_free()

func shell_interaction() -> void:
	if can_enter == false or sliding:
		return
	if colour <= 2:
		shell_jump_in()

func shell_kick() -> void:
	if is_instance_valid(shell_to_kick) == false:
		return
	skid.emitting = false
	shell_to_kick.direction = direction
	SoundManager.play_sfx(SoundManager.kick, self)
	animations.play("Kick")
	shell_to_kick.global_position.x += 4 * direction
	shell_to_kick.shell_moving = true
	shell_to_kick = null
	await get_tree().create_timer(0.5, false).timeout
	kicking = false
	can_kick = true

func create_troopa() -> void:
	const troopa_path = "res://Instances/Prefabs/Enemies/koopa_troopa.tscn"
	troopa_scene = load(troopa_path)
	var troopa_node = troopa_scene.instantiate()
	if entering_shell:
		troopa_node.global_position = global_position + Vector2(0, 4)
		troopa_node.colour = entering_shell.colour
		troopa_node.direction = direction
		if GameManager.current_level != null:
			GameManager.current_level.add_child(troopa_node)
		

func shell_jump_in() -> void:
	velocity.y = -150
	await get_tree().create_timer(0.25, false).timeout
	if is_instance_valid(entering_shell) == false:
		return
	hide()
	entering_shell.entity_present = true
	await get_tree().create_timer(0.25, false).timeout
	if is_instance_valid(entering_shell) == false:
		return
	if entering_shell.held == false and entering_shell.shell_moving == false and dead == false:
		pass
	else:
		return
	if colour == 2:
		summon_flash_shell()
	else:
		create_troopa()
	entering_shell.queue_free()
	queue_free()

func summon_flash_shell() -> void:
	var node = FLASHING_SHELL.instantiate()
	node.global_position = global_position + Vector2(0, 8)
	GameManager.current_level.add_child(node)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Shell:
		if area.get_parent().held or shell_to_kick == area.get_parent() or sliding or shell_sliding or can_kick == false or kicking or abs(area.get_parent().velocity.y) > 100:
			return
		if colour == 3:
			shell_to_kick = area.get_parent()
			velocity.x = area.get_parent().velocity.x
			if shell_to_kick.shell_moving:
				direction = -shell_to_kick.direction
			kicking = true
