class_name AchievementUnlocker
extends Node

@export var achievement: Achievement = null

var nulled := false

func unlock_achievement() -> void:
	if achievement != null and nulled == false:
		AchievementManager.unlock_achievement(achievement)

func nullify_achievement() -> void:
	nulled = true
