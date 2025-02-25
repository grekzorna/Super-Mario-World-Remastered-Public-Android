extends Enemy

@export var super_cape := false
@onready var animations: AnimationPlayer = $Sprite/Animations
const CAPE_FEATHER = preload("res://Instances/Prefabs/Items/cape_feather.tscn")
var jumping := false
const SHELLLESS_KOOPA = preload("res://Instances/Prefabs/Enemies/shellless_koopa.tscn")
var has_launched := false

var flying := false

func launch() -> void:
	if has_launched:
		return
	has_launched = true
	play_walking_animation()
	velocity.x = -100
	await get_tree().create_timer(0.5).timeout
	velocity.y = -200
	jumping = true
	await get_tree().create_timer(0.4).timeout
	flying = true
	play_flying_animation()
	jumping = false


func _physics_process(delta: float) -> void:
	if jumping:
		velocity.y += 10
	if flying:
		velocity.y = lerpf(velocity.y, 0, delta * 10)
	move_and_slide()

func death_animation() -> void:
	animations.play("Death")

func play_flying_animation() -> void:
	animations.play("RESET")
	await get_tree().process_frame
	if super_cape:
		animations.play("FlyFlash")
	else:
		animations.play("Fly")

func damage() -> void:
	if super_cape:
		summon_cape_feather()
		summon_koopa()
	else:
		die()

func summon_koopa() -> void:
	var node = SHELLLESS_KOOPA.instantiate()
	node.colour = 3
	node.global_position = global_position
	node.direction = direction
	add_sibling(node)
	queue_free()

func summon_cape_feather() -> void:
	var feather_node = CAPE_FEATHER.instantiate()
	feather_node.global_position = global_position
	feather_node.velocity.y = -200
	GameManager.current_level.add_child(feather_node)
	feather_node.velocity.y = -300
	feather_node.block_spawn()
	

func play_walking_animation() -> void:
	if super_cape:
		animations.play("WalkFlash")
	else:
		animations.play("Walk")
