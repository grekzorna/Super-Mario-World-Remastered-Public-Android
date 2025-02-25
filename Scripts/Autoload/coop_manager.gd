extends Node

var players := {}

var splitscreen := false

var player_1: Player = null
var player_2: Player = null
var player_3: Player = null
var player_4: Player = null

var player_amount := 0

@onready var splitscreen_ratios = [Vector2(0.5, 1), Vector2(0.5, 0.5), Vector2(0.5, 0.5)]

var coop_enabled := true
var waiting := false
signal wait_finished
@onready var splitscreen_canvas: CanvasLayer = $Splitscreen

signal player_spawned
signal players_exited_pipe

@onready var off_screen_icons = [$Player1OffScreenIcon, $Player2OffScreenIcon, $Player3OffScreenIcon, $Player4OffScreenIcon]

var player_colours = [Color.LIGHT_SKY_BLUE, Color.RED, Color.GREEN, Color.YELLOW]
const SMALL = ("res://Resources/PlayerPowerUpState/Small.tres")
const BIG = ("res://Resources/PlayerPowerUpState/Big.tres")

@onready var character_head_icons = [load("res://Assets/Sprites/Characters/Mario/HeadIcon.png"), load("res://Assets/Sprites/Characters/Luigi/HeadIcon.png"), load("res://Assets/Sprites/Characters/Toad/HeadIcon.png"), load("res://Assets/Sprites/Characters/Toadette/HeadIcon.png")]

var bubble_fly_away := false
const PLAYER = preload("res://Instances/Prefabs/Player.tscn")
@onready var player_characters = {0: load("res://Resources/Characters/Mario.tres"), 1: load("res://Resources/Characters/Luigi.tres"), 2: load("res://Resources/Characters/Toad.tres"), 3: load("res://Resources/Characters/Toadette.tres")}
var player_power_states = [SMALL, SMALL, SMALL, SMALL]
var player_power_overrides := [null, null, null, null]
var player_yoshis = [false, false, false, false]
var yoshi_colours = [Yoshi.colours.GREEN, Yoshi.colours.GREEN, Yoshi.colours.GREEN, Yoshi.colours.GREEN]
var player_device_ids := [0, 1, 2, 3]
var pipe_exiting := false
var players_connected := 1
var crown_player := -1

var camera_distance_zoom_enabled := false

@onready var coop_camera: Camera2D = $CoopCamera

var wait_finished_players = []
var active_players = {}
var alive_players = {}
var dead_players := {}
var game_overed_players := {}


@onready var PLAYER_SCENE = load("res://Instances/Prefabs/Player.tscn")
func _ready() -> void:
	for i in Input.get_connected_joypads():
		print("HI!" + str(Input.get_joy_name(i) + str(i)))

func spawn_players() -> void:
	player_amount = 0
	player_1 = get_first_any_player()
	await get_tree().physics_frame
	for i in players_connected - 1:
		var node = player_characters[i + 1].base_character_scene.instantiate()
		var id = i + 1
		node.player_id = id
		node.starting_direction = player_1.starting_direction
		node.character = player_characters[id]
		if is_instance_valid(player_1):
			if CoopManager.pipe_exiting:
				node.global_position = GameManager.current_level.pipes[TransitionManager.pipe_id].global_position
			else:
				node.global_position = player_1.global_position + Vector2((16 * id) * player_1.starting_direction, 0)
		GameManager.current_level.add_child(node)
		active_players[id] = node
		alive_players[id] = node
		node.camera.enabled = false
		coop_camera.enabled = true
		player_amount += 1
		if game_overed_players.has(node.player_id):
			game_overed_players[node.player_id] = node
			node.remove_from_game()
			alive_players.erase(node.player_id)
			player_amount -= 1
		elif dead_players.has(node.player_id):
			node.bubble_respawn()

func handle_pipe_exits(pipe_id := 0, direction := "") -> void:
	await get_tree().process_frame
	var pipe_players = alive_players.duplicate()
	var id := 0
	print(pipe_players)
	pipe_exiting = true
	GameManager.can_pause = false
	if is_instance_valid(GameManager.current_level.pipes.get(pipe_id)) == false:
		for i in pipe_players.values():
			i.can_crush = true
		pipe_exiting = false
		return
	var pipe: Pipe = GameManager.current_level.pipes[pipe_id]
	for i in pipe_players.values():
		if is_instance_valid(i):
			i.global_position = pipe.global_position
			i.hide()
			i.remove_from_game()
	await get_tree().create_timer(0.5).timeout
	for i in pipe_players.values():
		if is_instance_valid(i) == false:
			return
		if dead_players.has(i.player_id) == false:
			i.exit_pipe(pipe, direction)
		await get_tree().create_timer(0.5).timeout
	GameManager.can_pause = true
	players_exited_pipe.emit()
	pipe_exiting = false

func get_splitscreen_camera_offset() -> Vector2:
	match players_connected:
		2:
			return Vector2(152, 0)
		3:
			return Vector2(152, 180)
		4:
			return Vector2(152, 180)
		_:
			return Vector2.ZERO

func _process(delta: float) -> void:
	player_amount = 0
	coop_enabled = players_connected > 1
	for i in alive_players.values():
		if is_instance_valid(i):
			player_amount += 1
	handle_camera(delta)
	handle_offscreen_icons()

func boss_defeated(cutscene := "", secret := false) -> void:
	GameManager.star_points_goal = 0
	GameManager.course_clear.level_finish()
	MusicPlayer.play_boss_defeated_theme()
	for i in alive_players.values():
		i.state_machine.transition_to("LevelFinish", {"Boss" = true})
	await GameManager.course_clear.finished
	if cutscene != "":
		TransitionManager.transition_to_level(cutscene, GameManager.current_level)
	else:
		TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, true, "", false, secret)

func handle_camera(delta: float) -> void:
	if coop_enabled == false:
		coop_camera.enabled = false
		return
	if GameManager.autoscrolling:
		return
	if splitscreen:
		coop_camera.enabled = false
		return
	if is_instance_valid(GameManager.current_level):
		if is_instance_valid(GameManager.current_level.player) == false:
			return
		if is_instance_valid(coop_camera) == false:
			return
		if is_instance_valid(GameManager.current_level):
			coop_camera.limit_right = GameManager.current_level.camera_left_end_position
			coop_camera.limit_top = GameManager.current_level.camera_top_end_position + 16
			if GameManager.current_level.lock_camera:
				return
		var center_pos := Vector2.ZERO
		for i in alive_players.values():
			if is_instance_valid(i):
				i.camera.enabled = false
				center_pos += i.global_position
		coop_camera.enabled = true
		coop_camera.make_current()
		center_pos /= player_amount
		var target_position = center_pos
		if player_amount <= 1:
			var target = get_first_alive_player()
			if is_instance_valid(target) == false:
				target = get_first_active_player()
			if target == null:
				target = get_first_any_player()
			if target == null:
				return
			target_position = target.global_position
		if coop_camera.global_position.distance_to(target_position) < 16 or pipe_exiting:
			coop_camera.global_position = target_position
		else:
			coop_camera.global_position = lerp(coop_camera.global_position, target_position, delta * 20)
		if camera_distance_zoom_enabled:
			handle_distance_zoom(delta)
		else:
			coop_camera.zoom = Vector2.ONE
	else:
		coop_camera.global_position = Vector2.ZERO
		coop_camera.enabled = false

func reset_values() -> void:
	player_power_states = [SMALL, SMALL, SMALL, SMALL]
	game_overed_players = {}
	dead_players = {}
	player_yoshis = [false, false, false, false]

func handle_distance_zoom(delta: float) -> void:
	var player_dists = []
	var min_dist := Vector2.ZERO
	var max_dist := Vector2.ONE
	var distance := 0.0
	for i in active_players.values():
		player_dists.append(coop_camera.to_local(i.global_position))
	max_dist = player_dists.max()
	min_dist = player_dists.min()
	distance = min_dist.distance_to(max_dist)
	var target_zoom := (350 / distance)
	target_zoom = clamp(target_zoom, 0.01, 1)
	coop_camera.zoom = lerp(coop_camera.zoom, Vector2(target_zoom, target_zoom), delta * 20)

func get_player_input_str(action, player_id) -> String:
	return action + "_" + str(player_id)

func get_first_any_player() -> Player:
	for i in players.values():
		if is_instance_valid(i):
			return i
	return null

func get_first_active_player() -> Player:
	for i in active_players.values():
		if is_instance_valid(i):
			return i
	return null

func get_first_alive_player() -> Player:
	for i in alive_players.values():
		if is_instance_valid(i):
			return i
	return null

func get_closest_player(point := Vector2.ZERO) -> Player:
	var player: Player = null
	var distances := []
	for i in alive_players.values():
		if is_instance_valid(i):
			distances.append(point.distance_to(i.global_position))
	if distances.is_empty() == false:
		return alive_players.values()[distances.find(distances.min())]
	if is_instance_valid(player) == false:
		player = get_first_any_player()
	return player

func handle_offscreen_icons() -> void:
	if splitscreen:
		return
	if players_connected == 1:
		return
	if GameManager.secret_clear:
		return
	if is_instance_valid(GameManager.current_level) == false or players_connected > 1:
		for i in off_screen_icons:
			i.visible = false
	var player_index := 0
	for player in players.values():
		if is_instance_valid(player) == false:
			break
		var icon = off_screen_icons[player_index]
		icon.visible = not player.on_screen_notifier.is_on_screen() and not player.dead and not pipe_exiting and not player.out_of_game and player.state_machine.state.name.contains("Pipe") == false
		var player_sprite = icon.get_node("Sprite")
		player_sprite.sprite_frames = load("res://Resources/PlayerSpriteFrames/" + player.character.character_name + "/" + player.power_state.sprite_frame_name+ ".tres")
		if player_sprite.sprite_frames.has_animation(player.sprite.animation):
			player_sprite.play(player.sprite.animation)
		player_sprite.speed_scale = player.sprite.speed_scale
		player_sprite.scale.x = 0.75 * player.sprite.scale.x
		icon.global_position = player.global_position
		var cam_pos = coop_camera.get_screen_center_position()
		var extents = cam_pos
		icon.global_position.x = clamp(icon.global_position.x, cam_pos.x - 224, cam_pos.x + 224)
		icon.global_position.y = clamp(icon.global_position.y, cam_pos.y - 119, cam_pos.y + 119)
		player_index += 1

func setup_players() -> void:
	spawn_players()
	for i in players.values():
		pass

func call_to_players(player_list := {}, call := _ready) -> void:
	for i in player_list.values():
		i.call(call)

func wait_for_players(wait_time := 5) -> void:
	wait_finished_players.clear()
	waiting = true
	await get_tree().create_timer(wait_time, false).timeout
	if waiting == false:
		return
	waiting = false
	wait_finished.emit()

func add_wait_player(player: Player) -> void:
	wait_finished_players.append(player)
	if wait_finished_players.size() >= alive_players.size():
		await get_tree().physics_frame
		waiting = false
		wait_finished.emit()
