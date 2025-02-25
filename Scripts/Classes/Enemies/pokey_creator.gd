extends Node2D

var height := 3

const POKEY_SEGMENT = preload("res://Instances/Prefabs/Enemies/pokey_segment.tscn")

var pokeys := []

static var id := 0

func _ready() -> void:
	$Visuals.queue_free()
	await $VisibleOnScreenNotifier2D.screen_entered
	id += 1
	await get_tree().physics_frame
	for i in CoopManager.active_players.values():
		if i.riding_yoshi:
			height = 5
	for i in height:
		create_pokey((i + 1) * 16)

func _physics_process(delta: float) -> void:
	for i in pokeys:
		if is_instance_valid(i):
			if i.is_on_wall():
				for x in pokeys:
					if is_instance_valid(x):
						x.direction *= -1


func create_pokey(y_pos := 0) -> void:
	var node = POKEY_SEGMENT.instantiate()
	node.global_position = global_position
	node.global_position.y -= y_pos
	node.global_position.y += 16
	node.id = id
	pokeys.append(node)
	GameManager.current_level.add_child(node)
