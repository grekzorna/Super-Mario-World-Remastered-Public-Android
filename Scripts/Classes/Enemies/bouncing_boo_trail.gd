extends Enemy

var x_dir := -1
var y_dir := -1

var speed := 50

func _ready() -> void:
	$Sprite.play(["1", "2", "3"].pick_random())

func _physics_process(delta: float) -> void:
	if is_on_floor() or is_on_ceiling():
		y_dir *= -1
	if is_on_wall():
		x_dir *= -1
	velocity = speed * Vector2(x_dir, y_dir)
	$Sprite.scale.x = x_dir
	move_and_slide()

const BOO_TRAIL = preload("res://Instances/Prefabs/Enemies/boo_trail.tscn")

func summon_trail_thing() -> void:
	var node = BOO_TRAIL.instantiate()
	node.get_node("Sprite").frame = randi_range(0, 5)
	node.global_position = global_position
	add_sibling(node)
	node.global_position = global_position
	node.scale.x = x_dir
