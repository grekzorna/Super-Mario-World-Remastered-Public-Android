extends Enemy
@onready var death_sprite: AnimatedSprite2D = $Sprite
const WRENCH = preload("res://Instances/Prefabs/Projectiles/wrench.tscn")
@onready var sprite_3: Sprite2D = $Sprite3

func _physics_process(delta: float) -> void:
	var player = CoopManager.get_closest_player(global_position)
	if player.global_position.x < 0:
		direction = -1 
	else:
		direction = 1
	sprite_3.scale.x = direction

func throw() -> void:
	var node = WRENCH.instantiate()
	node.direction = -direction
	node.global_position = $WrenchPosition.global_position
	GameManager.current_level.add_child(node)

func damage() -> void:
	death_sprite.show()
	die()
