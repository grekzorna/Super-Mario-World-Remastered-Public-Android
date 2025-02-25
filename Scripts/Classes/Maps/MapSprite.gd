class_name AutumnSprite
extends Sprite2D

@export var autumn_texture: Texture2D = null

@export var overhaul_only := false

var force_autumn := true
@onready var standard_texture: Texture = self.texture

func _ready() -> void:
	if is_instance_valid(GameManager.current_map):
		z_index = -1
	if GameManager.autumn:
		if overhaul_only:
			if SettingsManager.settings_file.autumn_type == 1:
				return
		if is_instance_valid(autumn_texture):
			texture = autumn_texture

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if is_instance_valid(autumn_texture):
			if force_autumn:
				texture = autumn_texture
			else:
				texture = standard_texture
