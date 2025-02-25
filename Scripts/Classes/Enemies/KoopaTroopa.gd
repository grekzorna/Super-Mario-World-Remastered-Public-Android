class_name KoopaTroopa
extends Enemy


@onready var held_item = preload("res://Instances/Prefabs/HeldObjects/koopa_shell.tscn")
@onready var fire_breath = preload("res://Instances/Prefabs/Projectiles/fire_breath.tscn")
@export_enum("Red", "Green", "Yellow", "Purple") var colour := 0
@export var winged := false
@export_enum("Horizontal", "Vertical") var red_fly_direction := 0
@export_enum("High", "Low", "Fly") var green_para_jump_height := 0
var can_hit := true
@onready var floor_check: RayCast2D = $FloorCheck


@onready var starting_position = global_position

@onready var shellless: PackedScene = preload("res://Instances/Prefabs/Enemies/shellless_koopa.tscn")
@onready var wings: AnimatedSprite2D = $Sprite/Wings
@onready var autumn_sprite: Sprite2D = $AutumnSprite
@onready var autumn_wings: AnimatedSprite2D = $AutumnSprite/Wings
@onready var animations: AnimationPlayer = $Sprite/Animations

var para_red_move := 0.0

@export var turning := false


func spawn() -> void:
	sprite = $Sprite
	floor_check = $FloorCheck
	if colour == 0:
		spit_item = fire_breath
	else:
		spit_item = held_item
	$ShellDeath.texture = get_shell_sprite()
	sprite.texture = get_sprite()
	autumn_sprite.texture = get_autumn_sprite()
	sprite.visible = not GameManager.autumn
	autumn_wings.visible = winged
	autumn_sprite.visible = GameManager.autumn
	if GameManager.autumn:
		wings = autumn_wings
		sprite = autumn_sprite
		animations = $AutumnSprite/Animations
	sprite.scale.x = direction
	if colour == 0 and winged:
		red_fly(1 / 60)
		await get_tree().physics_frame
	$VisibleOnScreenEnabler2D.set_enable_node_path($VisibleOnScreenEnabler2D.get_path_to(self))

func damage() -> void:
	var kick_direction := 1
	if is_instance_valid(player):
		if player.global_position.x > global_position.x:
			kick_direction = -1
		else:
			kick_direction = 1
	if winged:
		winged = false
		velocity.y = 50
	else:
		direction = kick_direction
		spawn_shell()
		spawn_shellless_koopa()
		queue_free()

func spawn_shell(flipped := false) -> void:
	var node = held_item.instantiate()
	node.global_position = global_position + Vector2(0, 0)
	node.colour = colour
	call_deferred("add_sibling", (node))
	if flipped:
		node.flipped = true
		node.entity_present = true
		node.velocity.y = -200
		node.moving = false

func death_animation() -> void:
	sprite.hide()
	sprite = $ShellDeath
	sprite.show()

func _process(_delta: float) -> void:
	wings.visible = winged
	set_collision_layer_value(4, is_on_floor())

func melee_attack() -> void:
	spawn_shell(true)
	SoundManager.play_sfx(SoundManager.kick, self)
	queue_free()


func spawn_shellless_koopa() -> void:
	var node = shellless.instantiate()
	node.global_position = global_position - Vector2(4 * -direction, 0)
	node.sliding = true
	node.colour = colour
	player = CoopManager.get_closest_player(global_position)
	node.shell_sliding = true
	if is_instance_valid(player):
		if player.global_position.x > global_position.x:
			direction = -1
		else:
			direction = 1
	node.troopa_scene = load(self.scene_file_path)
	GameManager.current_level.call_deferred("add_child", (node))
	node.velocity.x = 200 * direction
	node.direction = direction

func _physics_process(delta: float) -> void:
	velocity.x = 35 * direction
	velocity.y += 10
	floor_check.position.x = abs(floor_check.position.x) * direction
	floor_check.floor_normal = get_floor_normal()
	if (floor_check.is_colliding() == false) and is_on_floor():
		if (colour == 0 or colour == 3) and can_hit:
			flip_direction()
	if is_on_wall() && can_hit:
		flip_direction()
	if winged:
		if colour == 0:
			red_fly(delta)
		else:
			if green_para_jump_height == 2:
				para_red_move += 1 * delta
				global_position.x -= 32 * delta
				global_position.y = starting_position.y + sin(para_red_move * 4) * 4
			else: 
				if is_on_floor():
					if green_para_jump_height == 0:
						velocity.y = -300
					else:
						velocity.y = -200
				move_and_slide()
	else:
		velocity.y = clamp(velocity.y, -9999, 200)
		move_and_slide()

func red_fly(delta) -> void:
	var target_direction := 1
	para_red_move += 1 * delta
	if red_fly_direction == 0:
		global_position.x = (starting_position.x + sin(para_red_move) * 56)
		global_position.x -= 56
		if (sin(para_red_move + delta)) >= sin(para_red_move): 
			target_direction = 1
		else:
			target_direction = -1
		global_position.y = starting_position.y + sin(para_red_move * 4) * 4
	elif red_fly_direction == 1:
		global_position.y = (starting_position.y + sin(para_red_move) * 56)
		global_position.y -= 56
		target_direction = -1
	if target_direction != direction and not turning:
		flip_direction()

func play_turn_animation() -> void:
	animations.play("Turn")
	await animations.animation_finished
	sprite.scale.x = direction
	animations.play("default")

func get_sprite() -> Texture2D:
	var sprites = [preload("res://Assets/Sprites/Enemys/Koopas/KoopaTroopas/Red.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaTroopas/Green.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaTroopas/Yellow.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaTroopas/Blue.png"),]
	return sprites[colour]

func get_autumn_sprite() -> Texture2D:
	var sprites = [preload("res://Assets/Sprites/Enemys/Koopas/MaskedKoopas/Red.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/MaskedKoopas/Green.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/MaskedKoopas/Yellow.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/MaskedKoopas/Blue.png"),]
	return sprites[colour]

func get_shell_sprite() -> Texture2D:
	var sprites = [preload("res://Assets/Sprites/Enemys/Koopas/KoopaShells/Red.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaShells/Green.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaShells/Yellow.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaShells/Blue.png"),]
	var autumn_sprites = [preload("res://Assets/Sprites/Enemys/Koopas/Masks/Red.png"),
						preload("res://Assets/Sprites/Enemys/Koopas/Masks/Green.png"),
						preload("res://Assets/Sprites/Enemys/Koopas/Masks/Yellow.png"),
						preload("res://Assets/Sprites/Enemys/Koopas/Masks/Blue.png"),]
	if GameManager.autumn:
		return autumn_sprites[colour]
	return sprites[colour]


func flip_direction() -> void:
	can_hit = false
	play_turn_animation()
	direction *= -1
	await get_tree().create_timer(0.1, false).timeout
	can_hit = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	check_hit(area)
