extends Node2D

@export var main_texture: Texture = null
@export var show_clouds := true
@onready var texture: Sprite2D = $ParallaxLayer/MainTexture
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var clouds: Parallax2D = $Clouds

@onready var og_bg := get_parent().get_node("StaticBG")

func _ready() -> void:
	clouds.visible = show_clouds
	if GameManager.encore_mode == false:
		queue_free()
		return
	texture.texture = main_texture
	await get_tree().process_frame
	if is_instance_valid(og_bg):
		og_bg.queue_free()
	get_parent().add_child(canvas_modulate.duplicate())
	canvas_modulate.queue_free()
