extends CharacterBody2D

@onready var yoshi_scene = preload("res://Instances/Prefabs/Interactables/yoshi.tscn")
@onready var sprite: Sprite2D = $Sprite
@onready var oneup_scene = preload("res://Instances/Prefabs/Items/1_up.tscn")

@export_enum("Green", "Red", "Blue", "Yellow") var colour := 0

var custom_item: PackedScene = null

const egg_textures := [preload("res://Assets/Sprites/Characters/Yoshi/Eggs/Green.png"),
							preload("res://Assets/Sprites/Characters/Yoshi/Eggs/Red.png"),
							preload("res://Assets/Sprites/Characters/Yoshi/Eggs/Blue.png"),
							preload("res://Assets/Sprites/Characters/Yoshi/Eggs/Yellow.png")]

const shell_texture := preload("res://Assets/Sprites/Particles/YoshiEggShell.png")

var particles = [shell_texture, shell_texture, shell_texture, shell_texture]

var can_hatch := false
var hatched := false

@export var force_spawn := false

func _ready() -> void:
	Yoshi.yoshi_amount = clamp(Yoshi.yoshi_amount, 0, 99)
	sprite.texture = egg_textures[colour]

func _physics_process(delta: float) -> void:
	velocity.y += 15
	if is_on_floor() and not hatched:
		can_hatch = true
	if can_hatch:
		hatched = true
		can_hatch = false
		hatch()
	if is_on_floor():
		velocity.x = lerpf(velocity.x, 0, delta * 5)
	move_and_slide()

func hatch() -> void:
	await get_tree().create_timer(0.5, false).timeout
	sprite.frame = 1
	SoundManager.play_sfx(SoundManager.yoshi_hatch, self)
	await get_tree().create_timer(0.5, false).timeout
	ParticleManager.summon_four_part(particles, global_position - Vector2(0, 8), 8)
	if calc_total_yoshis() >= CoopManager.players_connected and not custom_item and not force_spawn :
		spawn_1up()
	elif not custom_item:
		spawn_yoshi()
	else:
		spawn_item()
	queue_free()

func calc_total_yoshis() -> int:
	var amount := 0
	for i in CoopManager.players.values():
		if is_instance_valid(i):
			if i.riding_yoshi:
				amount += 1
	for i in GameManager.current_level.get_children():
		if i is Yoshi:
			amount += 1
	return amount

func spawn_yoshi() -> void:
	var yoshi_node = yoshi_scene.instantiate()
	yoshi_node.global_position = global_position
	get_parent().add_child(yoshi_node)
	yoshi_node.colour = colour
	SoundManager.play_sfx(SoundManager.yoshi_mount, self)
	yoshi_node.play_hatch_animation()

func spawn_item() -> void:
	var node = custom_item.instantiate()
	node.global_position = global_position - Vector2(0, 8)
	add_sibling(node)

func spawn_1up() -> void:
	var oneup = oneup_scene.instantiate()
	oneup.global_position = global_position - Vector2(0, 8)
	get_parent().add_child(oneup)
