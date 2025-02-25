extends Enemy

@export var scene: PackedScene = null

@export var autumn_sprite: Texture = null

func _ready() -> void:
	sprite = $Parachute.get_child(0)
	if autumn_sprite != null and GameManager.autumn:
		await get_tree().process_frame
		$Parachute/Galoomba.texture = autumn_sprite

func _physics_process(delta: float) -> void:
	velocity.y = 40
	if is_on_floor():
		summon_galoomba()
	move_and_slide()

func damage() -> void:
	summon_galoomba()

func summon_galoomba() -> void:
	var node = scene.instantiate()
	node.global_position = global_position
	GameManager.current_level.add_child(node)
	queue_free()
