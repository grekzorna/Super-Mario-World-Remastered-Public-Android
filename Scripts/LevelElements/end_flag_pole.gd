extends Node2D

var no_players := true ## No Players? {:(

@export var secret := false
@onready var base_sprite: Sprite2D = $Base/Sprite
@onready var flag_sprite: AnimatedSprite2D = $Flag
@onready var pole_hitbox: Area2D = $Pole/Hitbox

signal start_sequence
signal flag_down

var players := []

func _ready() -> void:
	if secret:
		base_sprite.frame = 1
		flag_sprite.play("Secret")

func pole_hitbox_hit(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_hit(area.get_parent())

func top_hitbox_hit(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_hit(area.get_parent())
		GameManager.add_life(1, area.get_parent().global_position)

func player_hit(player: Player) -> void:
	player.level_finish()
	player.global_position.x = global_position.x - 6
	player.global_position.y = clamp(player.global_position.y, to_global(Vector2(global_position.x, -160)).y, to_global(Vector2(global_position.x, -16)).y)
	player.state_machine.transition_to("FlagPole", {"Pole" = self})
	players.append(player)
	if no_players:
		no_players = false
		if CoopManager.players_connected > 1:
			await get_tree().create_timer(CoopManager.players_connected, false).timeout
		else:
			await get_tree().create_timer(0.5, false).timeout
		start_finish()

func start_finish() -> void:
	GameManager.secret_clear = secret
	start_sequence.emit()
	CoopManager.bubble_fly_away = true
	for i in CoopManager.alive_players.values():
		if players.has(i) == false:
			i.state_machine.transition_to("BubbleRevive")
	CoopManager.bubble_fly_away = true
	$Animations.play("SlideDown")
	await $Animations.animation_finished
	pole_hitbox.queue_free()
	flag_down.emit()
	for i in players:
		i.state_machine.transition_to("LevelFinish")
	GameManager.course_clear.level_finish()
	if secret:
		SoundManager.play_sfx(SoundManager.checkpoint, self)
