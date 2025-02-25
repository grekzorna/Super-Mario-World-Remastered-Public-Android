extends Node2D

@onready var og_tiles = get_parent()



var new_tiles

static var clone := false

func _ready() -> void:
	if clone:
		queue_free()
		return
	if og_tiles:
		clone = true
		new_tiles = og_tiles.duplicate()
		viewport.add_child(new_tiles)

func _exit_tree() -> void:
	clone = false
@export var viewport: SubViewport = null
@export var camera: Camera2D = null

func _process(delta: float) -> void:
	camera.set_custom_viewport(viewport)
	camera.make_current()
	camera.global_position = get_tree().root.get_viewport().get_camera_2d().get_screen_center_position()
	viewport.set_world_2d(GameManager.get_viewport().get_world_2d())
	
	
