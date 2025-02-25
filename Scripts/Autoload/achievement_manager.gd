extends Node

var unlocked_achievements := []

var available_achievements: Array[Achievement] = []

var unlock_queue := []

var showing_animation := false

func get_achievement(achievement_name := "") -> Achievement:
	for i in available_achievements:
		if i.title == achievement_name:
			return i
	return null

func is_achievement_unlocked(achievement: Achievement) -> bool:
	return SaveManager.current_save.achievements_unlocked.has(achievement.resource_path)

func unlock_achievement(achievement: Achievement = null):
	if is_achievement_unlocked(achievement) or GameManager.playing_custom_level:
		return
	unlock_queue.push_front(achievement)
	SaveManager.current_save.achievements_unlocked.append(achievement.resource_path)
	go_through_queue()

func go_through_queue(force := false) -> void:
	if showing_animation and not force:
		return
	if unlock_queue.is_empty():
		return
	showing_animation = true
	await show_animation(unlock_queue.pop_back())
	if unlock_queue.is_empty() == false:
		go_through_queue(true)
	else:
		showing_animation = false

func show_animation(achievement: Achievement) -> void:
	$Ui/AchievementUnlockToast/Panel/Title.text = achievement.title
	$Ui/AchievementUnlockToast/Panel/Icon.texture = achievement.icon
	$Ui/AchievementUnlockToast/AnimationPlayer.play("Show")
	await $Ui/AchievementUnlockToast/AnimationPlayer.animation_finished
	return
