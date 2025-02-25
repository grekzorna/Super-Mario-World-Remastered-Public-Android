extends Enemy
const HAMMER_BRO_HAMMER = preload("res://Instances/Prefabs/Projectiles/hammer_bro_hammer.tscn")
@export var throw_direction := 1

@export var on_platform := false

func _physics_process(delta: float) -> void:
	if not on_platform:
		velocity.y += 15
		move_and_slide()

func damage() -> void:
	die()

func throw_hammer() -> void:
	SoundManager.play_sfx("res://Assets/Audio/SFX/hammer-bro-throw.wav", self)
	var node = HAMMER_BRO_HAMMER.instantiate()
	node.global_position = global_position - Vector2(0, 8)
	node.direction = throw_direction
	GameManager.current_level.add_child(node)
