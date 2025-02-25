@tool
@icon("res://Assets/Sprites/Editor/Icons/Checkpoint.png")
extends Node2D
@onready var pole_1_texture = preload("res://Assets/Sprites/Objects/CheckpointPole1.png")
@onready var pole_2_texture = preload("res://Assets/Sprites/Objects/CheckPointPole2.png")

@onready var bar_1: Node2D = $Bar1
@onready var bar_2: Node2D = $Bar1/Bar2
@onready var tape: Sprite2D = $Bar1/Bar
@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition

var poles = []
var player: Player

var frame := 0
@export var height := 4
@export var tape_offset := 0
@export var grounded := true

@export var checkpoint_position := Vector2.ZERO

func _ready() -> void:
	create_bars()
	if Engine.is_editor_hint() == false:
		player_spawn_position.hide()
		if GameManager.checkpoint_level != "":
			tape.queue_free()

func create_bars() -> void:
	for i in height:
		add_new_pole(pole_1_texture, i, bar_1)
		add_new_pole(pole_2_texture, i, bar_2, -24)

func _process(delta: float) -> void:
	player_spawn_position.global_position = to_global(checkpoint_position)
	if is_instance_valid(tape):
		tape.position.y = (-height * 8) + 26 + tape_offset

func add_new_pole(texture: Texture, i, parent, x_pos := 0) -> void:
	var bar = Sprite2D.new()
	bar.texture = texture
	bar.hframes = 4
	bar.vframes = 3
	parent.add_child(bar)
	poles.append(bar)
	bar.position.y = -8 * i
	bar.position.x = x_pos
	if i == 0 and not grounded:
		bar.frame_coords.y = 2
	elif i == height - 1:
		bar.frame_coords.y = 0
	else:
		bar.frame_coords.y = 1


func _on_timer_timeout() -> void:
	frame += 1
	if frame >=4:
		frame = 0
	for i in poles:
		i.frame_coords.x = frame

@onready var big = preload("res://Resources/PlayerPowerUpState/Big.tres")

func checkpoint() -> void:
	ParticleManager.summon_particle(ParticleManager.SPARKLE, tape.global_position)
	GameManager.add_score(1000, true, tape.global_position)
	tape.queue_free()
	SoundManager.play_sfx(SoundManager.checkpoint, self)
	if player.power_state == player.small_power_state:
		player.set_power_state(big)
	if player.carrying and player.carry_target is Player or player.carried:
		if is_instance_valid(player.carry_target):
			if player.carry_target.power_state == player.small_power_state:
				player.carry_target.set_power_state(big)
		if is_instance_valid(player.carrying_player):
			if player.carrying_player.power_state == player.small_power_state:
				player.carrying_player.set_power_state(big)
	GameManager.current_level.save_objects()
	GameManager.checkpoint_level = GameManager.current_level.scene_file_path
	GameManager.checkpoint_level_name = GameManager.current_level.level_name
	GameManager.checkpoint_position = to_global(checkpoint_position)
	await GameManager.current_level.save_objects()
	GameManager.check_point_run_states = GameManager.run_states

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		checkpoint()
