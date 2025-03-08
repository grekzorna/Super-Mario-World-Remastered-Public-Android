extends Node

static var coins := 0
static var lives := 5
static var dragon_coins := 0
static var score := 0
static var star_points := 0.0
var star_points_goal := 0

var coins_in_level := 0

var time := 300
@onready var message_animation: AnimationPlayer = $UI/Message/AnimationPlayer
@onready var speedrun_timer: Control = $UI/SpeedrunTimer
@onready var item_drop = preload("res://Instances/Parts/reserve_item_drop.tscn")
const CUSTOM_LEVEL_SELECT = ("res://Instances/UI/Menus/custom_level_select.tscn")
signal pipe_exited
var timer_frozen := false
var autoscrolling := false
var current_level= null
var current_map = null
var player: Player = null
var vs_mode := false
var player_power_state: PlayerPowerUpState = null
var pipe_exit_position := Vector2.ZERO
var main_area = null
var checkpoint_level := ""
var checkpoint_level_name := ""
var checkpoint_position := Vector2.ZERO
var starting_level_path := ""

var level_time := 0.0

var camera_shake := 0.0

var secret_clear := false

var inf_lives := false
var map_point_save := ""
var reserved_item: PlayerPowerUpState = null

var best_current_level_ghost: PlayerGhost

var ghost_index := 0.0
signal all_players_dead

var playing_custom_level := false
var custom_level_name := ""

var current_level_info: LevelInfo = null

var run_states = {}
var check_point_run_states = {}

var colours_enabled = [false, false, false, false]

var renderer: SubViewportContainer = null
@onready var message_rect: TextureRect = $UI/Message/MessageRect
@onready var course_clear: Control = $UI/CourseClear

var current_campaign: CampaignResource = preload("res://Resources/Campaigns/Vanilla.tres")

var can_alarm := true

var riding_yoshi := false

var peach_coin_collected := false

var autumn := false

var yoshi_present := false
var yoshi_stored := false
var starting_level := ""
var can_close_message := false

var coin_counter_coins_collected := 0

var game_paused := false

var current_level_route: PlayerGhost

var can_pause := true

var current_area_map_points = {}
var custom_level_autoloads = []
var dragon_coins_collected := [] ## THIS CONTAINS THE RUN COINS

var current_run_d_coins := [] ## THIS IS THE COINS THAT ARE COLLECTED WITHIN THE RUN

var current_map_path := ""
var red_coins_collected := 0
var current_map_area: MapArea = null
var time_played := 0.0
var running := false
var has_touchscreen := true



var key_exiting := false

var all_coins_collected := false
@onready var save_animation: AnimationPlayer = $UI/SavingText/Animation



const RESERVE_ITEM_DROP = preload("res://Instances/Parts/reserve_item_drop.tscn")
signal message_closed
signal star_ended

func _enter_tree() -> void:
	load_addons()

func _ready() -> void:
	var dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	if !dir.dir_exists_absolute(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/SuperMarioWorldRemastered"):
		dir.make_dir("SuperMarioWorldRemastered")
		dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/SuperMarioWorldRemastered")
		dir.make_dir("CustomLevels")
	dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/SuperMarioWorldRemastered")
	if !dir.dir_exists_absolute(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/SuperMarioWorldRemastered/CustomLevels"):
		dir.make_dir("CustomLevels")
	if !has_touchscreen:
		$Mobile.offset = Vector2(10000.0, 0.0)
func _process(delta: float) -> void:
	if is_instance_valid(player):
		riding_yoshi = player.riding_yoshi
	lives = clamp(lives, 0, 99)
	GameManager.time = clamp(GameManager.time, 0, 9999)
	if time == 100 and can_alarm:
		can_alarm = false
		SoundManager.play_sfx(SoundManager.hurry_up, player)
	elif time > 100:
		can_alarm = true
	if Input.is_action_just_pressed("ui_accept") and can_close_message:
		emit_signal("message_closed")
	if SaveManager.current_save != null:
		time_played += 1 * delta
	if is_instance_valid(GameManager.current_level) and is_instance_valid(CoopManager.get_first_any_player()):
		level_time += 1 * delta
	
	if OS.get_name() == "Android" || OS.get_name() == "iOS" || OS.is_debug_build():
		match running:
			true:
				$Mobile/Misc/RunToggle.modulate = Color(1, 0, 0, 0.95)
				Input.action_press("run_0")
			false:
				$Mobile/Misc/RunToggle.modulate = Color(1, 1, 1, 0.25)
				if !Input.is_action_pressed("run_0"):
					Input.action_release("run_0")
	

func _physics_process(delta: float) -> void:
	handle_camera_shake()

func apply_to_save() -> void:
	if SaveManager.current_save != {}:
		var save = SaveManager.current_save
		save.coins = coins
		save.lives = lives
		save.score = score
		save.autumn = autumn
		save.star_points = star_points
		save.colours_enabled = colours_enabled
		save.player_power_states = CoopManager.player_power_states
		save.player_yoshis = CoopManager.player_yoshis 
		save.yoshi_colours = CoopManager.yoshi_colours
		save.reserved_item = reserved_item
		if current_map:
			save.current_map = current_map_path
		SaveManager.current_save.time_played = time_played

func handle_discord_presence() -> void:
	pass


func show_message(message: Texture, show_time := 1) -> void:
	message_rect.texture = message
	await get_tree().physics_frame
	can_close_message = false
	get_tree().paused = true
	message_animation.play("Appear")
	await get_tree().create_timer(show_time).timeout
	can_close_message = true
	await message_closed
	can_close_message = false
	message_animation.play_backwards("Appear")
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false


@onready var game_over_text: AnimationPlayer = $UI/GameOverText/AnimationPlayer
@onready var circle_close: AnimationPlayer = $UI/CircleClose/Animations

func game_over() -> void:
	circle_close.play("Close")
	await circle_close.animation_finished
	game_over_text.play("Show")
	SoundManager.play_ui_sound(SoundManager.game_over)
	await get_tree().create_timer(8).timeout
	SaveManager.load_file(SaveManager.selected_file)
	GameManager.lives = 5 * CoopManager.players_connected
	SaveManager.current_save.lives = 5
	GameManager.score = 0
	GameManager.star_points = 0
	GameManager.checkpoint_level = ""
	GameManager.checkpoint_level_name = ""
	GameManager.reset_values()
	SaveManager.save_current_file()
	#TODO FIX THUS PATH!!!!
	if GameManager.playing_custom_level:
		TransitionManager.transition_to_menu("res://Instances/UI/Menus/custom_level_select.tscn", current_level)
	else:
		TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, false)
	GameManager.reset_values()
	await get_tree().create_timer(0.5, true).timeout
	game_over_text.play("RESET")
	circle_close.play("RESET")

func apply_save() -> void:
	var save = SaveManager.current_save
	coins = save.coins
	lives = save.lives
	score = save.score
	star_points = save.star_points
	colours_enabled = save.colours_enabled
	if save.reserved_item != null:
		reserved_item = load(save.reserved_item)
	autumn = save.autumn
	CoopManager.player_power_states = save.player_power_states
	CoopManager.player_yoshis = save.player_yoshis
	CoopManager.yoshi_colours = save.yoshi_colours
	time_played = save.time_played
	AchievementManager.unlocked_achievements = save.achievements_unlocked
	map_point_save = save.map_point_name
	var index := 0
	print(CoopManager.player_characters)
	for i: CharacterResource in CoopManager.player_characters.values():
		if i != null:
			if i.override_power_state != null:
				CoopManager.player_power_states[index] = i.override_power_state.resource_path
		index += 1

func enter_level(pipe := false, pipe_id := 0) -> void:
	pass

func shake_camera(amount := 1.0) -> void:
	camera_shake += amount

func reset_values() -> void:
	run_states = {}
	speedrun_timer.resume()
	GameManager.course_clear.cancel_finish()
	ghost_index = 0
	red_coins_collected = 0
	can_pause = true
	level_time = 0
	coins_in_level = 0
	dragon_coins = 0
	all_coins_collected = false
	peach_coin_collected = false
	Level.first_load = true
	GameManager.current_run_d_coins = []
	starting_level = ""
	checkpoint_level = ""
	checkpoint_level_name = ""
	checkpoint_position = Vector2.ZERO
	if lives <= 0:
		lives = 5 * CoopManager.players_connected
	CoopManager.game_overed_players.clear()
	CoopManager.dead_players.clear()
	if is_instance_valid(current_level):
		current_level.first_load = true
		current_level.pipe_enter = false
	if is_instance_valid(player):
		player.first_load = true
		player.current_level_route = PlayerGhost.new()
	if yoshi_stored:
		riding_yoshi = true
		yoshi_stored = false

func time_out() -> void:
	circle_close.play("Close")
	await circle_close.animation_finished
	game_over_text.play("Timeout")
	await get_tree().create_timer(3).timeout
	GameManager.checkpoint_level = ""
	GameManager.checkpoint_level_name = ""
	#TODO THIS ONE TOO!!
	if GameManager.playing_custom_level:
		TransitionManager.transition_to_menu("res://Instances/UI/Menus/custom_level_select.tscn", current_level)
	else:
		TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, false)
	GameManager.reset_values()
	await get_tree().create_timer(0.5, true).timeout
	game_over_text.play("RESET")
	circle_close.play("RESET")

func add_custom_autoload(autoload) -> void:
	if autoload is String:
		autoload = load(autoload)
	if autoload is Script:
		var script = autoload
		autoload = Node.new()
		autoload.set_script(script)
	elif autoload is PackedScene:
		autoload = autoload.instantiate()
	get_tree().root.add_child(autoload)
	custom_level_autoloads.append(autoload)

func animate_time_addition(amount := 10) -> void:
	for i in amount:
		time += 1
		await get_tree().create_timer(0.05, false).timeout

func add_score(amount := 100, show_note := true, note_position := Vector2.ZERO) -> void:
	if amount <= 0:
		return
	if show_note:
		create_score_note(note_position, amount)
	GameManager.score += amount

func add_coin(amount := 1, coin_position := Vector2.ZERO) -> void:
	coins += 1
	coins_in_level += 1
	coin_counter_coins_collected += 1
	if GameManager.coins >= 100:
		SoundManager.play_global_sfx(SoundManager.one_up)
		add_life(1, coin_position)
		GameManager.coins = 0

func drop_item(item_power: PlayerPowerUpState) -> void:
	if is_instance_valid(GameManager.current_level) == false:
		return
	SoundManager.play_ui_sound(SoundManager.reserve_item)
	var node = RESERVE_ITEM_DROP.instantiate()
	node.power = item_power
	node.global_position = get_viewport().get_camera_2d().get_screen_center_position() - Vector2(0, 119)
	current_level.add_child(node)
	reserved_item = null

func drop_current_held_item() -> void:
	if is_instance_valid(reserved_item):
		print(reserved_item)
		drop_item(reserved_item)

func add_item(item: PlayerPowerUpState) -> void:
	print(item)
	SoundManager.play_ui_sound(SoundManager.item_get)
	reserved_item = item

func add_life(amount := 1, note_position := Vector2.ZERO) -> void:
	create_1up_node(note_position, amount)
	GameManager.lives += 1
	for x in CoopManager.game_overed_players.values():
		if GameManager.lives <= 0:
			return
		elif x != null:
			x.bubble_respawn()
			GameManager.lives -= 1

func add_red_coin() -> void:
	red_coins_collected += 1
	if red_coins_collected >= 8:
		SoundManager.play_ui_sound(SoundManager.red_coins_complete, 1.25)
		red_coins_collected = 0

func create_1up_node(note_position: Vector2, amount := 1) -> void:
	var note_node = one_up_note_scene.instantiate()
	note_node.global_position = note_position
	note_node.get_node("Sprite").frame = amount - 1
	GameManager.current_level.add_child(note_node)

func create_score_note(note_position: Vector2, score_to_show := 100) -> void:
	var score_node = score_note_scene.instantiate()
	score_node.get_node("CenterContainer/ScoreText").text = str(score_to_show)
	score_node.global_position = note_position - Vector2(0, 16)
	GameManager.current_level.add_child(score_node)

@onready var score_note_scene = preload("res://Instances/Parts/score_note.tscn")
@onready var one_up_note_scene = preload("res://Instances/Parts/1_up_note.tscn")

func clear_custom_autoloads() -> void:
	for i in custom_level_autoloads:
		i.queue_free()
	custom_level_autoloads.clear()

func calculate_total_exits(save := {}) -> int:
	var exits := 0
	for x in [save.beaten_levels, save.special_beaten_levels]:
		for i in x:
			var level = load(i)
			if level != null:
				if level.counts_as_exit:
					exits += 1
	return exits

func calculate_total_drag_coins(save := {}) -> int:
	var coins := 0
	var data = save.dragon_coins_collected
	for i in data.values():
		for x in i:
			coins += 1
	return coins

func load_addons() -> void:
	if FileAccess.file_exists("user://modlist.json") == false:
		return
	
	var mod_list := {}
	var file = FileAccess.open("user://modlist.json", FileAccess.READ)
	mod_list = JSON.parse_string(file.get_as_text())
	for i in mod_list.keys():
		if mod_list[i] == true:
			ProjectSettings.load_resource_pack(i, true)

var original_camera_position := Vector2.ZERO
var target_camera: Camera2D = null

func handle_camera_shake() -> void:
	if is_instance_valid(get_viewport().get_camera_2d()) == false:
		return
	if target_camera != get_viewport().get_camera_2d():
		target_camera = get_viewport().get_camera_2d()
		original_camera_position = target_camera.offset
	if is_instance_valid(target_camera) == false:
		return
	var shake_amount = camera_shake / 10
	if camera_shake <= 0 or SettingsManager.settings_file.camera_shake == false:
		target_camera.offset = original_camera_position
	else:
		target_camera.offset = Vector2(randi_range(-shake_amount, shake_amount), randi_range(-shake_amount, shake_amount)) + original_camera_position
	camera_shake -= 1
	camera_shake = clamp(camera_shake, 0, 60)

func _on_timer_timeout() -> void:
	if (is_instance_valid(GameManager.current_level) and is_instance_valid(CoopManager.get_first_any_player()) and get_tree().paused == false):
		if can_pause:
			GameManager.time -= 1
	GameManager.time = clamp(GameManager.time, 0, 999999)

#region MOBILE_STUFF
############## DPAD ###############
## D-PAD UP
func _on_up_pressed() -> void:
	Input.action_press("ui_up")
	$Mobile/DPAD/Up.self_modulate = Color(1, 0, 0, 1)
func _on_up_released() -> void:
	Input.action_release("ui_up")
	$Mobile/DPAD/Up.self_modulate = Color(1, 1, 1, 1)
## D-PAD DOWN
func _on_down_pressed() -> void:
	Input.action_press("ui_down")
	$Mobile/DPAD/Down.self_modulate = Color(1, 0, 0, 1)
func _on_down_released() -> void:
	Input.action_release("ui_down")
	$Mobile/DPAD/Down.self_modulate = Color(1, 1, 1, 1)
## D-PAD LEFT
func _on_left_pressed() -> void:
	Input.action_press("ui_left")
	$Mobile/DPAD/Left.self_modulate = Color(1, 0, 0, 1)
func _on_left_released() -> void:
	Input.action_release("ui_left")
	$Mobile/DPAD/Left.self_modulate = Color(1, 1, 1, 1)
## D-PAD RIGHT
func _on_right_pressed() -> void:
	Input.action_press("ui_right")
	$Mobile/DPAD/Right.self_modulate = Color(1, 0, 0, 1)
func _on_right_released() -> void:
	Input.action_release("ui_right")
	$Mobile/DPAD/Right.self_modulate = Color(1, 1, 1, 1)
############## ABXY ###############
## A
func _on_a_pressed() -> void:
	Input.action_press("ui_accept")
	$Mobile/ABXY/A.self_modulate = Color(0.1, 0.1, 1, 1)
func _on_a_released() -> void:
	Input.action_release("ui_accept")
	$Mobile/ABXY/A.self_modulate = Color(1, 1, 1, 1)
## B
func _on_b_pressed() -> void:
	Input.action_press("ui_back")
	$Mobile/ABXY/B.self_modulate = Color(0.1, 0.1, 1, 1)
func _on_b_released() -> void:
	Input.action_release("ui_back")
	$Mobile/ABXY/B.self_modulate = Color(1, 1, 1, 1)
## X
func _on_x_pressed() -> void:
	Input.action_press("dialogue_proceed")
	$Mobile/ABXY/X.self_modulate = Color(0.1, 0.1, 1, 1)
func _on_x_released() -> void:
	Input.action_release("dialogue_proceed")
	$Mobile/ABXY/X.self_modulate = Color(1, 1, 1, 1)
## Y
func _on_y_pressed() -> void:
	Input.action_press("delete_save")
	$Mobile/ABXY/Y.self_modulate = Color(0.1, 0.1, 1, 1)
func _on_y_released() -> void:
	Input.action_release("delete_save")
	$Mobile/ABXY/Y.self_modulate = Color(1, 1, 1, 1)
############## Miscellanous ###############
## START
func _on_start_pressed() -> void:
	Input.action_press("start")
	Input.action_press("reload")
	Input.action_press("apply_settings")
func _on_start_released() -> void:
	Input.action_release("start")
	Input.action_release("reload")
	Input.action_release("apply_settings")
## RUN_TOGGLE
func _on_check_box_toggled() -> void:
	running = !running
#endregion
