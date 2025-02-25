@icon("res://Assets/Sprites/Editor/Icons/Level.png")
class_name Level
extends Node

var pipes = {}
var pipe_exit_position := Vector2.ZERO

var exiting_pipe := 0
var pipe_enter := false
@export var time := 400
@export var override_time := false
@export var hide_hud := false
var level_name := "Empty Level Name"
@export var level_music: AudioStreamInteractive = null
@export var autumn_music: AudioStreamInteractive = null
@export var custom_victory_theme: AudioStream = null
@export var custom_death_theme: AudioStream = null
@export var use_reverb := false
@export var lock_camera := false
@export var camera_left_end_position := 1000000 ## ITS NOT ACTUALLY THE LEFT SIDE OF THE LEVEL ITS THE RIGHT SIDE, IM JUST DUMB, CANNOT CHANGE IT NOW, OTHERWISE ALL THE VALS IN EACH LEVEL WILL BE LOST SORRY
@export var camera_top_end_position := -1000000
var in_interior := false
var best_level_time: PlayerGhost
const LEVEL_WALLS = preload("res://Instances/Parts/level_walls.tscn")
@onready var coin = preload("res://Instances/Prefabs/Items/coin.tscn")
@onready var empty_block = preload("res://Instances/Prefabs/Blocks/empty_block.tscn")
@onready var spin_block = preload("res://Instances/Prefabs/Blocks/spin_block.tscn")
const QUESTION_BLOCK = preload("res://Instances/Prefabs/Blocks/question_block.tscn")
const PHYSICS_COIN = preload("res://Instances/Prefabs/Items/physics_coin.tscn")
var saved_level_objects = []
const DROP_SHADOW_RENDERER = preload("res://Instances/Prefabs/drop_shadow_renderer.tscn")
signal p_switch_ended

static var first_load := true

signal stopwatch_start


var score_save := 0

var player: Player = null

var p_switch_active := false
var silver_switch_active := false

func _enter_tree() -> void:
	pipes = {}
	GameManager.current_level = self

func _ready() -> void:
	if GameManager.current_map_path == "":
		GameManager.inf_lives = false
	for i in get_children():
		if i is Player:
			player = i
	GameManager.can_pause = true
	add_child(LEVEL_WALLS.instantiate())
	if is_instance_valid(player):
		if CoopManager.player_characters[0].base_character_scene.resource_path != "res://Instances/Prefabs/Player.tscn":
			var node = CoopManager.player_characters[0].base_character_scene.instantiate()
			var old_player = CoopManager.get_first_any_player()
			node.global_position = old_player.global_position
			add_child(node)
			old_player.queue_free()
		if CoopManager.coop_enabled:
			CoopManager.setup_players()
	if first_load:
		GameManager.time = time
	elif override_time:
		GameManager.time = time
	first_load = false
	GameManager.current_level = self
	load_objects()
	hide_level_guide()
	get_pipes()
	
	TransitionManager.current_level = self
	AudioServer.set_bus_effect_enabled(2, 0, use_reverb)
	if not GameManager.starting_level:
		GameManager.starting_level = self.level_name
		GameManager.starting_level_path = scene_file_path
	ready.emit()
	add_drop_shadows()
	spawn()
	await TransitionManager.level_transitioned
	DragonCoin.check_drag_coins()
	PeachCoin.check_if_collected()
	enter_level()
	ready_override()
	await get_tree().physics_frame
	if MusicPlayer.music_override_persistent == false:
		MusicPlayer.stop_music_override(null, true)

func ready_override() -> void:
	pass

func spawn() -> void:
	pass

func add_drop_shadows() -> void:
	var node = DROP_SHADOW_RENDERER.instantiate()
	add_child(node)

func hide_level_guide() -> void:
	for i in get_children():
		if i is Sprite2D:
			if is_instance_valid(i.texture):
				if i.texture.resource_path.contains("LevelGuides"):
					i.hide()

func get_pipes() -> void:
	pass

func save_objects(dict := {}) -> void:
	saved_level_objects.clear()
	for i in get_children(true):
		saved_level_objects.append(i.name)
	GameManager.run_states[self.name] = saved_level_objects

func load_objects() -> void:
	if GameManager.run_states.has(self.name):
		saved_level_objects = GameManager.run_states[self.name]
	else:
		return
	if saved_level_objects.is_empty():
		return
	
	for i in get_children():
		if saved_level_objects.find(i.name) == -1:
			if (i is Player or i is ColourSwitchBlockEmpty) == false:
				i.queue_free()

func return_to_map(completed := false) -> void:
	TransitionManager.transition_to_map(GameManager.current_map, self, completed, GameManager.map_point_save)
	GameManager.current_level = null

func get_pipe_index(pipe_id: int) -> int:
	var index = 0
	for i in pipes.values():
		if i == pipe_id:
			return index
		index += 1
	return 0

func p_switch() -> void:
	MusicPlayer.p_switch()
	p_switch_active = true
	p_switch1()
	await get_tree().create_timer(12, false).timeout
	p_switch_active = false
	p_switch2()
	emit_signal("p_switch_ended")

func p_switch1(node = self) -> void:
	for i in node.get_children():
		if i is Coin:
			spawn_empty_block(i.global_position, true)
			i.queue_free()
		elif i is PSwitchCoin:
			spawn_coin(i.global_position, true)
			i.queue_free()
		elif i is EmptyBlock:
			spawn_coin(i.global_position, false, true)
			i.queue_free()
		elif i is PSwitchBlockSecret:
			spawn_question_block(i.global_position)
			i.queue_free()
		elif i is Door:
			if i.p_switch:
				i.show()
		elif i is TileMap:
			p_switch1(i)
		elif i is TileMapLayer:
			p_switch1(i)

func _process(delta: float) -> void:
	if silver_switch_active:
		silver_switch()

func silver_switch_activate() -> void:
	MusicPlayer.p_switch()
	silver_switch_active = true
	await get_tree().create_timer(10, false).timeout
	MusicPlayer.stop_music_override(MusicPlayer.P_SWITCH)
	silver_switch_active = false

func silver_switch() -> void:
	for i in get_children():
		if i is Enemy:
			if is_instance_valid(i.get_node_or_null("VisibleOnScreenEnabler2D")):
				if i.get_node_or_null("VisibleOnScreenEnabler2D").is_on_screen() == false:
					return
			if i.can_silver_switch == false:
				return
			spawn_silver_coin(i.global_position)
			i.queue_free()
			
func p_switch2(node = self) -> void:
	for i in node.get_children():
		if i is Coin:
			if i.secret:
				i.queue_free()
			else:
				spawn_empty_block(i.global_position)
				i.queue_free()
		if i is Door:
			if i.p_switch:
				i.hide()
		if i is TileMap:
			p_switch2(i)
		if i is EmptyBlock:
			if i.p_switch:
				spawn_coin(i.global_position)
				i.queue_free()
		if i is QuestionBlock:
			if i.p_switch:
				spawn_coin(i.global_position)
				i.queue_free()
		
func spawn_spin_block(position := Vector2.ZERO) -> void:
	await get_tree().process_frame
	var block_node = spin_block.instantiate()
	block_node.global_position = position
	add_child(block_node)

func spawn_silver_coin(position := Vector2.ZERO) -> void:
	var node = PHYSICS_COIN.instantiate()
	node.global_position = position
	node.silver = true
	add_child(node)

func spawn_question_block(position := Vector2.ZERO) -> void:
	await get_tree().process_frame
	var block_node = QUESTION_BLOCK.instantiate()
	block_node.global_position = position
	block_node.p_switch = true
	add_child(block_node)

func spawn_empty_block(position := Vector2.ZERO, first := false) -> void:
	await get_tree().process_frame
	var block_node = empty_block.instantiate()
	block_node.global_position = position
	block_node.p_switch = first
	add_child(block_node)

func spawn_coin(position := Vector2.ZERO, secret := false, empty := false) -> void:
	await get_tree().process_frame
	var coin_node = coin.instantiate()
	coin_node.global_position = position
	coin_node.p_switch = true
	coin_node.secret = secret
	coin_node.empty_block = empty
	add_child(coin_node)

func get_exiting_direction(id: int) -> void:
	get_tree().call_group("Pipes", "get_id")

func enter_level() -> void:
	await TransitionManager.pipe_enter
	exiting_pipe = TransitionManager.pipe_id
	if GameManager.current_level.pipes.has(exiting_pipe):
		CoopManager.handle_pipe_exits(TransitionManager.pipe_id, GameManager.current_level.pipes[TransitionManager.pipe_id].enter_direction)
	else:
		CoopManager.pipe_exiting = false
