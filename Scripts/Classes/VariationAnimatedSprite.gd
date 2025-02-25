class_name VariationAnimatedSprite
extends AnimatedSprite2D

@export var frames: Array[SpriteFrames]
@export var settings_value := ""

func _ready() -> void:
	if frames.is_empty():
		return
	if sprite_frames != frames[SettingsManager.sprite_settings[settings_value]]:
		stop()
		sprite_frames = frames[SettingsManager.sprite_settings[settings_value]]
		play(animation)
