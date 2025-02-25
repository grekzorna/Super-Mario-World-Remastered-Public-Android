class_name ReznorEnemy
extends Enemy
const REZNOR_FIREBALL = preload("res://Instances/Prefabs/Projectiles/reznor_fireball.tscn")
static var amount := 0

func _ready() -> void:
	await get_tree().create_timer(0.25, false).timeout
	$Sprite.play("Idle")
	await get_tree().create_timer(randi_range(1, 5)).timeout
	$Timer.start(randi_range(1, 10))

func _physics_process(delta: float) -> void:
	velocity.y += 15
	move_and_slide()

func melee_damage() -> void:
	die()

func shoot_fireball() -> void:
	var target_player: Player = CoopManager.get_closest_player(global_position)
	var dir = global_position.direction_to(target_player.global_position)
	var node = REZNOR_FIREBALL.instantiate()
	node.global_position = global_position
	node.direction_vector = dir
	GameManager.current_level.add_child(node)
	$Sprite.play("Fire")
	await get_tree().create_timer(0.5, false).timeout
	$Sprite.play("Idle")
	$Timer.start(randi_range(1, 10))
