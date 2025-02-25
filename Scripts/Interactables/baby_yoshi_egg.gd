extends CharacterBody2D

@onready var yoshi_scene = preload("res://Instances/Prefabs/HeldObjects/baby_yoshi.tscn")
@onready var sprite: Sprite2D = $Sprite
@onready var oneup_scene = preload("res://Instances/Prefabs/Items/1_up.tscn")

@export_enum("Green", "Red", "Blue", "Yellow") var colour := 0

const egg_textures := [preload("res://Assets/Sprites/Characters/Yoshi/Eggs/BabyGreen.png"),
							preload("res://Assets/Sprites/Characters/Yoshi/Eggs/BabyRed.png"),
							preload("res://Assets/Sprites/Characters/Yoshi/Eggs/BabyBlue.png"),
							preload("res://Assets/Sprites/Characters/Yoshi/Eggs/BabyYellow.png")]

var can_hatch := false
var hatched := false

func _ready() -> void:
	sprite.texture = egg_textures[colour]

func _physics_process(delta: float) -> void:
	velocity.y += 15
	if is_on_floor() and not hatched:
		can_hatch = true
	if can_hatch:
		hatched = true
		can_hatch = false
		hatch()
	move_and_slide()

func hatch() -> void:
	await get_tree().create_timer(0.5, false).timeout
	sprite.frame = 1
	SoundManager.play_sfx(SoundManager.yoshi_hatch, self)
	await get_tree().create_timer(0.5, false).timeout
	if GameManager.yoshi_present:
		spawn_1up()
	else:
		spawn_yoshi()
	queue_free()

func spawn_yoshi() -> void:
	var yoshi_node = yoshi_scene.instantiate()
	yoshi_node.colour = colour
	yoshi_node.global_position = global_position
	get_parent().add_child(yoshi_node)
	
	SoundManager.play_sfx(SoundManager.yoshi_mount, self, 1.5)

func spawn_1up() -> void:
	var oneup = oneup_scene.instantiate()
	get_parent().add_child(oneup)
	oneup.global_position = global_position - Vector2(0, 8)
