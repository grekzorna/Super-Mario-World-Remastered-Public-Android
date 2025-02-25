extends TextureRect

var collected := false

@export var collected_texture: Texture

func _ready() -> void:
	await get_tree().physics_frame
	if collected:
		texture = collected_texture
