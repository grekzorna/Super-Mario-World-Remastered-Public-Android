@tool
extends Node2D

@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition

var player: Player
@onready var sprite: AnimatedSprite2D = $Sprite
var crossed := false
@export var checkpoint_position := Vector2.ZERO

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		player_spawn_position.hide()
	if GameManager.checkpoint_level != "":
		crossed = true
		play_animation(GameManager.checkpoint_character)


func _process(delta: float) -> void:
	player_spawn_position.global_position = to_global(checkpoint_position)


@onready var big = preload("res://Resources/PlayerPowerUpState/Big.tres")

func checkpoint() -> void:
	if crossed:
		play_animation(CoopManager.player_characters[GameManager.checkpoint_character])
		return
	crossed = true
	play_animation(CoopManager.player_characters[player.player_id])
	ParticleManager.summon_particle(ParticleManager.SPARKLE, global_position)
	GameManager.add_score(1000, true)
	SoundManager.play_sfx(SoundManager.checkpoint, self)
	GameManager.checkpoint_character = CoopManager.player_characters[player.player_id]
	if player.power_state == player.small_power_state:
		player.power_up(big)
	if player.carrying and player.carry_target is Player or player.carried:
		if is_instance_valid(player.carry_target):
			if player.carry_target.power_state == player.small_power_state:
				player.carry_target.power_up(big)
		if is_instance_valid(player.carrying_player):
			if player.carrying_player.power_state == player.small_power_state:
				player.carrying_player.power_up(big)
	GameManager.current_level.save_objects()
	GameManager.checkpoint_level = GameManager.current_level.scene_file_path
	GameManager.checkpoint_level_name = GameManager.current_level.level_name
	GameManager.checkpoint_position = to_global(checkpoint_position)
	await GameManager.current_level.save_objects()
	GameManager.check_point_run_states = GameManager.run_states
	print(GameManager.checkpoint_level)

func play_animation(character := 0) -> void:
	sprite.play(str(character) + "Hit")
	await sprite.animation_finished
	sprite.play(str(character) + "Loop")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if not crossed:
			player = area.get_parent()
		checkpoint()
