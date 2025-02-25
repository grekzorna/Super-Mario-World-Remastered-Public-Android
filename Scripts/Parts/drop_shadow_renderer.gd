extends Node2D

@export var viewport: SubViewport = null
@export var camera: Camera2D = null

var world_viewport: Viewport = null

func _ready() -> void:
	world_viewport = get_viewport()
	viewport.world_2d = (world_viewport.get_world_2d())
	camera.set_custom_viewport(viewport)
	camera.make_current()

func _physics_process(delta: float) -> void:
	camera.global_position = world_viewport.get_camera_2d().get_screen_center_position()
	global_position = camera.global_position
	$SubViewportContainer.visible = SettingsManager.settings_file.drop_shadows

func _exit_tree() -> void: # WE NEED THIS FUNCTION SO BAD OMFG CAUSE OTHERWISE THE WHOLE GAME JUST FUCKING DIES WHEN THE LEVEL IS UNLOADED
	viewport.world_2d = null
