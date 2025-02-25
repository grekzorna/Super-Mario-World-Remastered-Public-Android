extends Enemy

const VOLCANO_PLANT_BULLETS = preload("res://Instances/Prefabs/Projectiles/volcano_plant_bullets.tscn")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity.y += 15
	move_and_slide()

func shoot_bullets() -> void:
	var bullet_node = VOLCANO_PLANT_BULLETS.instantiate()
	bullet_node.global_position = global_position - Vector2(0, 8)
	GameManager.current_level.add_child(bullet_node)
