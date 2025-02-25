extends Block

const move_speed := 50

@onready var starting_y = global_position.y

@onready var question_scene = preload("res://Instances/Prefabs/Blocks/question_block.tscn")

var mario: Player = null

var direction := -1
var flap: float = 0

func _physics_process(delta: float) -> void:
	global_position.x += (move_speed * direction) * delta
	flap += 1 * delta
	global_position.y = starting_y + sin(flap * 4) * 16


func block_hit_override() -> void:
	var question_node = question_scene.instantiate()
	question_node.item = item
	question_node.coin_amount = coin_amount
	question_node.global_position = global_position
	get_parent().add_child(question_node)
	question_node.block_hit("Up")
	queue_free()
