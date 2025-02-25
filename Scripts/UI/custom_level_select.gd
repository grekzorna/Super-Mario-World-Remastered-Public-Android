extends Control

const CUSTOM_LEVEL_SELECTOR = preload("res://Instances/UI/CustomLevelSelector.tscn")

const level_dir = ("user://CustomLevels/")

var levels = []

var level_nodes := []

var active := true

signal closed

signal warning_show

var selected_level: LevelInfo

@onready var container: VBoxContainer = $ListContainer/MarginContainer/Container
@onready var no_level_error: Label = $NoLevelError
@onready var refresh_animation: AnimationPlayer = $RefreshNotification/Animation
@onready var arrow: CenterContainer = $Arrow
@onready var level_info: NinePatchRect = $InputPrompts/LevelInfo

@onready var list_container: ScrollContainer = $ListContainer

@onready var circle_animation: AnimationPlayer = $CircleFade/CircleAnimation

@onready var title: Label = $InputPrompts/LevelInfo/Margin/Container/Title
@onready var author: Label = $InputPrompts/LevelInfo/Margin/Container/Author
@onready var difficulty: TextureProgressBar = $InputPrompts/LevelInfo/Margin/Container/DifficultyContainer/TextureProgressBar
@onready var safety_warning: NinePatchRect = $SafetyWarning
@onready var description: Label = $InputPrompts/LevelInfo/Margin/Container/MarginContainer/Description

@onready var loading_text: Label = $LoadingText

var selected_index := 0

static var error_load := false

signal safety_accepted

signal level_selected
var selected_level_node = null

var can_select := true

func _ready() -> void:
	if error_load:
		show_notification("Error loading Level!", SoundManager.wrong)
	error_load = false
	GameManager.playing_custom_level = false
	SaveManager.current_save = {}
	GameManager.custom_level_name = ""
	GameManager.starting_level = ""
	GameManager.starting_level_path = ""
	CoopManager.reset_values()
	GameManager.checkpoint_level = ""
	GameManager.checkpoint_level_name = ""
	GameManager.checkpoint_position = Vector2.ZERO
	GameManager.starting_level_path = ""
	MusicPlayer.stop_music_override(MusicPlayer.music_override.stream, true)
	MusicPlayer.stop_level_music()
	GameManager.clear_custom_autoloads()
	await get_tree().physics_frame
	get_custom_levels()

func open() -> void:
	pass

func _process(delta: float) -> void:
	no_level_error.visible = levels.is_empty()
	if levels.is_empty():
		selected_level = null
	menu_input()
	
	if selected_level_node != null:
		var arrow_position = Vector2(8, selected_level_node.global_position.y + (4))
		arrow.global_position = lerp(arrow.global_position, arrow_position, delta * 20)
	

func tween_scroll(value := 0) -> void:
	list_container.scroll_vertical += value

func select_level(level := {}) -> void:
	selected_level = parse_json(level)
	GameManager.current_level_info = selected_level
	GameManager.starting_level = level.level_scene_path
	GameManager.starting_level_path = level.level_scene_path
	SaveManager.current_save = SaveManager.save_file_template
	SaveManager.apply_data()
	can_select = false
	level_selected.emit()
	await $CharacterSelect.finished
	enter_level()



func enter_level() -> void:
	SoundManager.play_ui_sound(SoundManager.enter_save)
	circle_animation.play("Close")
	GameManager.playing_custom_level = true
	await get_tree().create_timer(1).timeout
	loading_text.show()
	await get_tree().create_timer(0.2).timeout
	var path := selected_level.level_scene_path
	if selected_level.start_cutscene_path != "":
		path = selected_level.start_cutscene_path
	GameManager.starting_level_path = path
	TransitionManager.transition_to_level(path, self, false, null, true)

func cancelled_entry() -> void:
	can_select = true

func parse_json(json := {}) -> LevelInfo:
	var level_info = LevelInfo.new()
	
	for i in [
		"level_title", 
		"level_scene_path", 
		"start_cutscene_path",
		"has_secret_exit", 
		"yoshi_allowed", 
		"has_dragon_coins", 
		"title_image"
		]:
		
		level_info.set(i, json.get(i))
	
	return level_info

func menu_input() -> void:
	pass
	
	if Input.is_action_just_pressed("move_down_0"):
		selected_index += 1
		SoundManager.play_ui_sound(SoundManager.select)
		if selected_index >= 10:
			tween_scroll(16)
	elif Input.is_action_just_pressed("move_up_0"):
		selected_index -= 1
		SoundManager.play_ui_sound(SoundManager.select)
		if selected_index <= levels.size() - 10:
			tween_scroll(-16)
	selected_index = clamp(selected_index, 0, level_nodes.size() - 1)
	if level_nodes.is_empty() == false:
		selected_level_node = level_nodes[selected_index]
	for i in level_nodes:
		i.highlighted = i == level_nodes[selected_index]
	if levels.is_empty() == false and can_select:
		if Input.is_action_just_pressed("ui_accept"):
			select_level(selected_level_node.level)
	if Input.is_action_just_pressed("ui_back"):
		TransitionManager.transition_to_menu(TransitionManager.TITLE_SCREEN, self)


func get_custom_levels() -> void:
	for x in ["user://CustomLevels/"]:
		for i in DirAccess.get_directories_at(x):
			get_level_info(x + i)

func get_level_info(level_dir := "") -> void:
	if FileAccess.file_exists(level_dir + "/levelinfo.json"):
		var file = FileAccess.open(level_dir + "/levelinfo.json", FileAccess.READ)
		var lvl_json = JSON.parse_string(file.get_as_text())
		create_level_option(lvl_json)

func clear_level_list() -> void:
	for i in container.get_children():
		i.queue_free()
	levels.clear()

func create_level_option(level) -> void:
	var level_node = CUSTOM_LEVEL_SELECTOR.instantiate()
	level_node.level = level
	$ListContainer/MarginContainer/Container.add_child(level_node)
	levels.append(level)
	level_nodes.append(level_node)

func refresh_list() -> void:
	clear_level_list()
	get_custom_levels()
	show_notification("List Refreshed!")

func show_notification(message := "BLANK", sfx = SoundManager.coin) -> void:
	get_node("RefreshNotification/Text").text = message
	refresh_animation.play("RESET")
	refresh_animation.play("Appear")
	SoundManager.play_ui_sound(sfx)
