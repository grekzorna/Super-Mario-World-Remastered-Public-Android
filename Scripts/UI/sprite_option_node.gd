class_name SpriteSelectionNode
extends SelectableOptionNode

@export var textures: Array[Texture2D] = []

@export var sprite: Sprite2D = null

func _ready() -> void:
	if sprite != null:
		sprite.z_index = 10
		sprite.reparent($Control, false)
	sprite.top_level = true
	$Control/RemoteTransform2D.remote_path = $Control/RemoteTransform2D.get_path_to(sprite)

func update_2() -> void:
	sprite.visible = highlighted
	if textures[selected_index] != null:
		sprite.texture = textures[selected_index]
