@icon("res://Assets/Sprites/Editor/Icons/GoalPost.png")
extends Node2D

@onready var slider: Sprite2D = $PostA/Slider

var hit := false

var player: Player = null
@export var secret := false

@export var slider_value := 0.0

var points := 0.0

signal player_passed
signal all_points

var crossed_players := []

var crossed := false

var can_bonus := true

var bonus := false

@onready var ten_star: Sprite2D = $"CanvasLayer/Stars/10"
@onready var one_star: Sprite2D = $"CanvasLayer/Stars/1"
@onready var black_out: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var stars: Node2D = $CanvasLayer/Stars
@onready var enemy_kill: CollisionShape2D = $EnemyKillBox/CollisionShape2D
@onready var blackout: ColorRect = $Blackout

func _ready() -> void:
	blackout.hide()
	GameManager.secret_clear = secret
	if secret:
		for i in [$PostA, $PostA/PostB]:
			i.frame += 2

func _process(delta: float) -> void:
	if is_instance_valid(slider):
		slider.position.y = lerpf(64, -58, slider_value)
		points = lerpf(1, 25, slider_value) * 2
	if int(points) == 49:
		points = 50
	
	var units = (int(points) % 10)
	var tens = (points - units) / 10
	one_star.frame_coords.x = units
	ten_star.frame_coords.x = tens

func _physics_process(delta: float) -> void:
	if crossed:
		for i in $EnemyKillBox.get_overlapping_areas():
			if i.owner is Enemy:
				i.owner.coin_die(true)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if not hit:
		if area.get_parent() is Player:
			player = area.get_parent()
			if player.dead or player.out_of_game or player.state_machine.state.name == "BubbleRevive":
				return
			player = area.get_parent()
			player.level_finish()
			bonus = true
			player_past(true)

var has_bonused := false

func player_past(bonus := false) -> void:
	GameManager.secret_clear = secret
	crossed = true
	if player.state_machine.state.name == "FinishWait" or player.state_machine.state.name == "LevelFinish":
		return
	player_passed.emit()
	player.level_finish_powerup_reward()
	GameManager.run_states = {}
	if not bonus:
		SoundManager.play_sfx(SoundManager.bullet, self)
	if bonus:
		can_bonus = false
		if int(points) == 50:
			all_points.emit()
		if is_instance_valid(slider):
			slider.queue_free()
		GameManager.star_points_goal = points
	elif can_bonus:
		if is_instance_valid(slider):
			coin_die()
		GameManager.star_points_goal = 0
	player.state_machine.transition_to("FinishWait")
	crossed_players.append(player)
	GameManager.run_states = {}
	if crossed_players.size() >= CoopManager.players_connected:
		_on_wait_timer_timeout()
		$WaitTimer.queue_free()
		return
	if CoopManager.alive_players.size() > 1:
		$WaitTimer.start(CoopManager.alive_players.size() * 2)
	else:
		_on_wait_timer_timeout()

func delete_tape() -> void:
	crossed = true
	if is_instance_valid(slider):
		slider.queue_free()

func coin_die(auto_collect := false) -> void:
	summon_coin(auto_collect)
	ParticleManager.summon_particle(ParticleManager.PUFF, global_position)
	slider.queue_free()

const PHYSICS_COIN = preload("res://Instances/Prefabs/Items/physics_coin.tscn")

func summon_coin(auto_collect := false) -> void:
	var node = PHYSICS_COIN.instantiate()
	node.global_position = slider.global_position
	node.auto_collect = true
	add_sibling(node)
	node.velocity.y = -100


func show_stars() -> void:
	has_bonused = false
	stars.show()
	await get_tree().create_timer(3).timeout
	$CanvasLayer/Stars/AnimationPlayer.play("FadeOut")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not hit:
		if area.get_parent() is Player:
			player = area.get_parent()
			if player.dead or player.out_of_game or player.state_machine.state.name == "BubbleRevive":
				return
			player.level_finish()
			player_past()

func finish_start() -> void:
	hit = true
	crossed = true


func _on_wait_timer_timeout() -> void:
	if bonus:
		show_stars()
	GameManager.course_clear.level_finish()
	for i in CoopManager.alive_players.values():
		if crossed_players.has(i) == false:
			i.state_machine.transition_to("BubbleRevive")
		else:
			i.state_machine.transition_to("LevelFinish")


func _on_enemy_kill_box_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
