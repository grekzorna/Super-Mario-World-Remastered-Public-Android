@tool
extends LevelBG

@export var og_bg: LevelBG = null

func spawn() -> void:
	if Engine.is_editor_hint() == true:
		return
	if GameManager.autumn == false or SettingsManager.settings_file.autumn_type == 1:
		queue_free()
	elif is_instance_valid(og_bg):
		og_bg.queue_free()
