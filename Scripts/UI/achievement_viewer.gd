extends Control

const ACHIEVEMENT_CONTAINER = preload("res://Instances/UI/achievement_container.tscn")

@export var achievements: Array[Achievement] = []
@onready var vanilla_campaign = preload("res://Resources/Campaigns/Vanilla.tres")
var active := false

signal closed

func _ready() -> void:
	if is_instance_valid(GameManager.current_campaign):
		achievements = GameManager.current_campaign.achievements
	if SaveManager.current_save == null:
		SaveManager.current_save = SaveManager.save_file_template
	add_achievements()

func _physics_process(delta: float) -> void:
	if active:
		if Input.is_action_pressed("move_down_0"):
			if Input.is_action_pressed("run_0"):
				tween_scroll(512 * delta)
			else:
				tween_scroll(256 * delta)
		elif Input.is_action_pressed("move_up_0"):
			if Input.is_action_pressed("run_0"):
				tween_scroll(-512 * delta)
			else:
				tween_scroll(-256 * delta)
		if Input.is_action_just_pressed("ui_back"):
			close_menu()
		if Input.is_action_just_pressed("debug_info"):
			for i in achievements:
				AchievementManager.unlock_achievement(i)

func add_achievements() -> void:
	for i in achievements:
		spawn_achievements_node(i)
	spawn_achievements_node(null)

func spawn_achievements_node(achievement: Achievement = null) -> void:
	var node = ACHIEVEMENT_CONTAINER.instantiate()
	node.achievement = achievement
	if achievement != null:
		if achievement.hidden_achievement:
			if SaveManager.current_save.achievements_unlocked.has(achievement.resource_path) == false:
				node.queue_free()
				return
		node.unlocked = SaveManager.current_save.achievements_unlocked.has(achievement.resource_path)
	$MarginContainer/ScrollContainer/VBoxContainer.add_child(node)

func open_menu() -> void:
	$Animations.play("Open")
	active = true

func close_menu() -> void:
	closed.emit()
	$Animations.play_backwards("Open")
	active = false

func tween_scroll(amount := 0) -> void:
	$MarginContainer/ScrollContainer.scroll_vertical += amount
