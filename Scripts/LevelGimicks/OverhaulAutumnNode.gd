class_name AutumnNode
extends ConditionalReplaceNode

@export var overhaul_only := false

func condition() -> bool:
	if not overhaul_only:
		return GameManager.autumn
	return GameManager.autumn == true and SettingsManager.settings_file.autumn_type == 0
