extends PowerUp

signal collected

@export var collect_achievement: Achievement = null

func spawn() -> void:
	if collect_achievement != null:
		$AchievementUnlocker.achievement = collect_achievement
		if SaveManager.current_save != {}:
			print(SaveManager.current_save)
			if SaveManager.current_save.achievements_unlocked.has(collect_achievement.resource_path):
				queue_free()

func hitbox_hit(area: Area2D) -> void:
	if area.get_parent() is Player and can_grab:
		GameManager.add_life(3, global_position)
		if collect_achievement != null:
			$AchievementUnlocker.unlock_achievement()
		collected.emit()
		queue_free()
