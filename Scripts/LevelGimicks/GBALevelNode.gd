class_name GBALevelNode
extends ConditionalReplaceNode

func condition() -> bool:
	return SettingsManager.settings_file.level_layout_type == 1
