extends Enemy

const jump_force := -350

@export var shoots_fireball := false

@onready var starting_position := global_position
@onready var player_detect_area: Area2D = $PlayerDetect/Area
@onready var autumn_sprite: AnimatedSprite2D = $AutumnSprite


var jump_queued := false

var can_jump := true

var player_block := false

func spawn() -> void:
	if GameManager.autumn:
		sprite.hide()
		autumn_sprite.show()
		sprite = autumn_sprite
		
	global_position.y += 16
	await get_tree().create_timer(4, false).timeout
	jump()

func _physics_process(delta: float) -> void:
	velocity.y += 8
	player_block = player_detect_area.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is Player)
	velocity.y = clamp(velocity.y, -99999, 25)
	global_position.y = clamp(global_position.y, -999999, starting_position.y + 16)
	move_and_slide()
const JUMPING_PIRANHA_FIREBALL = preload("res://Instances/Prefabs/Projectiles/jumping_piranha_fireball.tscn")
func damage() -> void:
	die()

func melee_damage() -> void:
	die()

func fireball() -> void:
	for i in [-1, 1]:
		var node = JUMPING_PIRANHA_FIREBALL.instantiate()
		node.global_position = global_position
		node.direction = i
		add_sibling(node)

func jump() -> void:
	if player_block:
		jump_queued = true
		$Timer.start()
		return
	if can_jump:
		can_jump = false
	else:
		$Timer.start()
		return
	jump_queued = false
	velocity.y = jump_force
	await get_tree().create_timer(0.5, false).timeout
	if shoots_fireball:
		fireball()
	await get_tree().create_timer(5, false).timeout
	can_jump = true
	$Timer.start()


func _on_timer_timeout() -> void:
	if player_block:
		$Timer.start(2)
	else:
		jump()
