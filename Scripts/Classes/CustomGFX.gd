class_name CustomSprite
extends Sprite2D

@export var texture_path := "" ## Filepath of the texture RELATIVE to the base custom level folder.

func _ready() -> void:
	await get_tree().physics_frame
	texture = load(GameManager.custom_level_name + texture_path)
