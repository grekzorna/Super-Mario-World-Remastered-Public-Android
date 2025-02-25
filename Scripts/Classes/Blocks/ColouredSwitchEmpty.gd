@tool
class_name ColourSwitchBlockEmpty
extends Node2D

@export_enum("Yellow", "Green", "Blue", "Red") var colour := 0

@onready var sprite: Sprite2D = $Sprite

@onready var block = load("res://Instances/Prefabs/Blocks/coloured_switch_block.tscn")

@onready var colour_hexes := [Color.YELLOW, Color.GREEN, Color.DODGER_BLUE, Color.DEEP_PINK]

func _ready() -> void:
	await get_tree().physics_frame
	if Engine.is_editor_hint() == false:
		if GameManager.colours_enabled[colour]:
			spawn_block()

func spawn_block() -> void:
	var block_node = block.instantiate()
	block_node.colour = colour
	block_node.global_position = global_position
	await get_tree().process_frame
	add_sibling(block_node)
	queue_free()

func _process(delta: float) -> void:
	sprite.modulate = colour_hexes[colour]
