extends TextureRect

@export var camera: Camera2D = null
@export var viewport: SubViewport = null

func _ready() -> void:
	camera.custom_viewport = viewport
	viewport.world_2d = camera.get_world_2d()

func _process(delta: float) -> void:
	scale = Vector2.ONE / get_parent().scale
	position = (Vector2(-240, -204) * scale)

func screenshot() -> void:
	camera.custom_viewport = viewport
	camera.enabled = true
	camera.make_current()
	texture = viewport.get_texture()
	await get_tree().process_frame
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	await get_tree().physics_frame
	var player: Player = get_parent().get_parent().player
	if is_instance_valid(player):
		player.hide()
		if is_instance_valid(player.held_object):
			player.held_object.hide()

func _exit_tree() -> void:
	viewport.world_2d = null
