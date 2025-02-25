extends Node2D
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var speech_animation: AnimationPlayer = $CanvasLayer/EndingSpeech/AnimationPlayer
const ENDING_FIREWORK = preload("res://Instances/Prefabs/Projectiles/ending_firework.tscn")
var player_position := [0.0, 0.0, 0.0, 0.0]
var center_position := 0.0
var target_position := 0.0
var direction := 1

var nodes_moved := 0

signal moved

var moving := false
var can_move := true

signal speech_start

func spawn() -> void:
	show()
	for i in CoopManager.alive_players.values():
		i.state_machine.transition_to("Freeze", {"Gravity" = true})
	animation.play("Fall")
	await animation.animation_finished
	await get_tree().create_timer(1, false).timeout
	calculate_positions()
	move_to_positions()

func _process(delta: float) -> void:
	if moving and can_move:
		if nodes_moved > CoopManager.alive_players.size():
			moved.emit()
			moving = false
			can_move = false
	sprite.scale.x = -direction

func calculate_positions() -> void:
	var first_player := CoopManager.get_first_alive_player()
	center_position = (first_player.global_position.x + global_position.x) / 2
	center_position = clamp(center_position, 72, 280)
	if global_position.x > center_position:
		direction = 1
	else:
		direction = -1
	target_position = center_position + 8 * direction 
	for i in CoopManager.alive_players.size():
		print(i)
		player_position[i] = center_position - (8 * direction)
		player_position[i] -= (16 * direction) * i * (4 / CoopManager.players_connected)
	print([target_position, player_position])

func move_to_positions() -> void:
	moving = true
	move_node_to_position(self, target_position, 48)
	for i in CoopManager.alive_players.size():
		move_node_to_position(CoopManager.alive_players.values()[i], player_position[i], 48)
	await moved
	await get_tree().create_timer(1.5, false).timeout
	start_kiss()
	await get_tree().create_timer(7, false).timeout
	SoundManager.play_global_sfx(preload("res://Assets/Audio/BGM/SMW/PeachSpeech.mp3"))
	speech_animation.play("Animated")
	for i in CoopManager.alive_players.values():
		i.current_animation = "Idle"
	await speech_animation.animation_finished
	await show_fireworks()
	TransitionManager.transition_to_level("res://Instances/Levels/staff_credits.tscn", GameManager.current_level)

func move_node_to_position(node: Node2D, destination := 0.0, speed := 32) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "global_position:x", destination, node.global_position.distance_to(Vector2(destination, 0)) / speed)
	if node is Player:
		if destination > node.global_position.x:
			node.direction = 1
		else:
			node.direction = -1
		node.state_machine.transition_to("Freeze", {"Animating" = true, "Gravity" = true})
		node.current_animation = "Walk"
		await tween.finished
		if node.global_position.x > global_position.x:
			node.direction = -1
		else:
			node.direction = 1
		node.current_animation = "Idle"
		nodes_moved += 1
	elif node == self:
		if destination > node.global_position.x:
			node.direction = 1
		else:
			node.direction = -1
		sprite.play("Walk")
		await tween.finished
		sprite.play("Idle")
		nodes_moved += 1
	return

func start_kiss() -> void:
	for i in CoopManager.alive_players.values():
		i.state_machine.transition_to("Freeze", {"Animating" = true})
	SoundManager.play_global_sfx(preload("res://Assets/Audio/BGM/SMW/PeachIntro.mp3"))
	for i in CoopManager.alive_players.size():
		var target_player: Player = CoopManager.alive_players.values()[i]
		move_node_to_position(self, target_player.global_position.x + 12 * target_player.direction)
		await get_tree().create_timer(1, false).timeout
		direction = -target_player.direction
		sprite.play("Kiss")
		SoundManager.play_sfx(SoundManager.swim, self, 1.25)
		target_player.current_animation = "PeachKiss"
		await get_tree().create_timer(0.5, false).timeout
	await move_node_to_position(self, target_position - 8 * direction)
	direction = -CoopManager.alive_players.values()[0].direction

func show_fireworks() -> void:
	var amount := 0
	var target_x := 32
	for i in CoopManager.players_connected:
		if amount % 2 == 0:
			target_x = 200
		else:
			target_x = 0
		summon_firework(CoopManager.player_characters[i].ending_firework_mask, Vector2(target_x, -200), CoopManager.player_characters[i].char_colour)
		amount += 1
		await get_tree().create_timer(3, false).timeout
	summon_firework(preload("res://Assets/Sprites/Characters/Peach/FireworkMask.png"), Vector2(0, -200), Color.HOT_PINK)
	await get_tree().create_timer(3, false).timeout
	summon_firework(preload("res://Assets/Sprites/Objects/HeartFireworkMask.png"), Vector2(100, -200), Color.LIGHT_PINK)
	await get_tree().create_timer(5, false).timeout
	return

func summon_firework(texture: Texture, work_position := Vector2.ZERO, colour := Color.WHITE) -> void:
	SoundManager.play_global_sfx("res://Assets/Audio/SFX/fall.wav")
	await get_tree().create_timer(1, false).timeout
	var node = ENDING_FIREWORK.instantiate()
	node.mask_texture = texture
	node.global_position = work_position
	add_sibling(node)
	node.modulate = colour
