class_name VariationSprite
extends Sprite2D

@export var textures: Array[Texture2D]
@export var settings_value := ""

func _ready() -> void:
	texture = textures[SettingsManager.sprite_settings[settings_value]]
