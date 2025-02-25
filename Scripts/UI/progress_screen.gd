extends Node

@export var current_area: MapArea = null

@onready var container: VBoxContainer = $UI/Board/Margin/Container
@onready var sections = container.get_children()
@onready var time_label: Label = $UI/Header/Container/Time/Label
@onready var score_label: Label = $UI/Header/Container/Score/Label2
@onready var lives_label: Label = $UI/Header/Container/LivesCoins/Lives/Label
@onready var coins_label: Label = $UI/Header/Container/LivesCoins/Coins/Label
@onready var peach_sprite: AnimatedSprite2D = $UI/Header/PeachSprite
@onready var achievement_viewer: Control = $UI/AchievementViewer
@onready var season_indicator: Sprite2D = $UI/Header/SeasonIndicator

@onready var player_icons := [$UI/Header/Container/LivesCoins/Lives/PlayerIcons/Player1, $UI/Header/Container/LivesCoins/Lives/PlayerIcons/Player2, $UI/Header/Container/LivesCoins/Lives/PlayerIcons/Player3, $UI/Header/Container/LivesCoins/Lives/PlayerIcons/Player4]

var level_areas := []

@onready var available_areas := []

var available_levels := 0

var area_index := 0

var level_index := 0

var active := true

func _ready() -> void:
	season_indicator.global_rotation_degrees = 180 if GameManager.autumn else 0
	season_indicator.visible = SaveManager.current_save.autumn_unlocked
	level_areas = GameManager.current_campaign.map_areas
	if SaveManager.current_save.game_beaten:
		$UI/Header/PeachIndicator/Animation.play("Clear")
	for i in level_areas:
		print(i.resource_path)
		if i.levels.any(func(level: LevelInfo): return SaveManager.current_save.unlocked_levels.has(level.resource_path)):
			available_areas.push_back(i)
	current_area = GameManager.current_map_area
	if SaveManager.current_save == null:
		SaveManager.load_file(0)
	$UI/Header/Container/Time/Label.text = format_stopwatch_time()
	area_index = available_areas.find(current_area)
	if area_index == -1:
		find_area()
	level_index = current_area.levels.find(GameManager.current_level_info)
	set_sections()
	update_stats()

func find_area() -> void:
	var index := 0
	for i in available_areas:
		print(GameManager.current_level_info.level_title)
		if i.levels.has(GameManager.current_level_info):
			current_area = available_areas[index]
			area_index = index
			return
		index += 1

func set_sections() -> void:
	available_levels = 0
	var index := 0
	for i in sections:
		i.level = null
	for i in current_area.levels:
		available_levels += 1
		sections[index].level = i
		index += 1
	for i in sections:
		i.update_info()

func update_stats() -> void:
	score_label.text = str(GameManager.score)
	lives_label.text = "*" + str(GameManager.lives)
	coins_label.text = "*" + str(GameManager.coins)
	for i in player_icons:
		i.hide()
	for i in CoopManager.players_connected:
		player_icons[i].show()
		player_icons[i].texture = CoopManager.player_characters[i].HUDLetter
	if CoopManager.players_connected == 1:
		player_icons[0].texture = CoopManager.player_characters[0].HUDTitle

func _physics_process(delta: float) -> void:
	if not active:
		return
	if Input.is_action_just_pressed("ui_back") and not achievement_viewer.active:
		TransitionManager.transition_to_map(GameManager.current_map_path, self)
	elif Input.is_action_just_pressed("ui_accept"):
		if (sections[level_index].level_completed or sections[level_index].secret_completed) and (current_area.levels[level_index].map_point_warp != "" and current_area.levels[level_index].map_scene_warp != ""):
			SoundManager.play_ui_sound(SoundManager.cape_get)
			warp_to_point()
		else:
			SoundManager.play_ui_sound(SoundManager.wrong)
	season_indicator.frame = int(GameManager.autumn)
	$UI/Board/Label.text = str(current_area.area_name)
	if Input.is_action_just_pressed("ui_left"):
		area_index -= 1
		SoundManager.play_ui_sound(SoundManager.select)
	if Input.is_action_just_pressed("ui_right"):
		area_index += 1
		SoundManager.play_ui_sound(SoundManager.select)
	level_index = clamp(level_index, 0, available_levels - 1)
	
	if Input.is_action_just_pressed("ui_up"):
		level_index -= 1
		SoundManager.play_ui_sound(SoundManager.select)
	if Input.is_action_just_pressed("ui_down"):
		level_index += 1
		SoundManager.play_ui_sound(SoundManager.select)
	if SaveManager.current_save.autumn_unlocked:
		if Input.is_action_just_pressed("spin_jump_0"):
			GameManager.autumn = not GameManager.autumn
			SoundManager.play_ui_sound(SoundManager.spin)
			tween_season_rotate()
	level_index = wrap(level_index, 0, available_levels)
	$UI/Board/Arrow.global_position.y = sections[level_index].global_position.y
	if sections[level_index].level_unlocked:
		$UI/Header/LevelTitle.text = sections[level_index].level.level_title.to_upper()
	else:
		$UI/Header/LevelTitle.text = ""
	if Input.is_action_just_pressed("run_0") and not achievement_viewer.active:
		achievement_viewer.open_menu()
		active = false
	area_index = wrap(area_index, 0, available_areas.size())
	current_area = available_areas[area_index]
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		print(current_area.resource_path)
		set_sections()

func tween_season_rotate() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(season_indicator, "global_rotation_degrees", 180 * int(GameManager.autumn), 0.2)

func warp_to_point() -> void:
	var map_scene = current_area.levels[level_index].map_scene_warp
	var point_path = current_area.levels[level_index].map_point_warp
	TransitionManager.transition_to_map(map_scene, self, false, point_path, true)

func format_stopwatch_time() -> String:
	var secs = str(int((fmod(GameManager.time_played, 60))))
	var mins = str(int((fmod(GameManager.time_played, 60 * 60) / 60)))
	var hrs = str(int((GameManager.time_played / (60 * 60))))
	if int(secs) < 10:
		secs = "0" + secs
	
	if int(mins) < 10:
		mins = "0" + mins
	
	if int(hrs) < 10:
		hrs = "0" + hrs
	
	var time_passed = hrs + ":" + mins + ":" + secs
	return time_passed

func achievement_closed() -> void:
	active = true
