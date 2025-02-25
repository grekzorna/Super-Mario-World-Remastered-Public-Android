extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite
const BOSS_BALL = preload("res://Instances/Prefabs/Enemies/Bosses/boss_ball.tscn")
@onready var player = GameManager.player
@onready var animations: AnimationPlayer = $Animations
@export var island: Node2D = null

var player_direction := 1
var hurt := false
signal defeated
var dying := false
var dead := false
var can_throw_ball := true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		if (self.to_local(player.global_position).y) <= (-2):
			player_bounce()
			damage(player.direction)
		else:
			player.damage()
	elif area.get_parent() is LavaArea:
		die()
	if area.get_parent() is Fireball:
		damage(area.get_parent().direction)
		area.get_parent().queue_free()

func _physics_process(delta: float) -> void:
	player = CoopManager.get_closest_player(global_position)
	if dying:
		global_position.y += 2 * delta
		return
	velocity.y += 15
	if global_position.x > player.global_position.x:
		player_direction = -1
	else:
		player_direction = 1
	sprite.scale.x = -player_direction
	if dead:
		velocity.y = clamp(velocity.y, 0, 25)
	move_and_slide()

func ball() -> void:
	if dead:
		return
	can_throw_ball = true
	velocity = Vector2.ZERO
	animations.play("Ball")
	await animations.animation_finished
	animations.play("Idle")

func spawn_ball() -> void:
	if hurt:
		return
	SoundManager.play_sfx(SoundManager.yoshi_spit, self)
	var ball_node = BOSS_BALL.instantiate()
	ball_node.direction = player_direction
	ball_node.global_position = global_position - Vector2(4 * player_direction, 16)
	GameManager.current_level.add_child(ball_node)

func die() -> void:
	dead = true
	velocity.x = 0
	dying = true
	animations.speed_scale = 2
	SoundManager.play_sfx(SoundManager.boss_burn, self)
	SoundManager.play_sfx(SoundManager.boss_flame, self)
	await get_tree().create_timer(1, false).timeout
	defeated.emit()
	island.can_tilt = false
	if name == "Iggy":
		CoopManager.boss_defeated("res://Instances/Levels/Cutscenes/Castle1.tscn")
	else:
		CoopManager.boss_defeated("res://Instances/Levels/Cutscenes/Castle7.tscn")
	await get_tree().process_frame
	queue_free()

func player_bounce() -> void:
	player.bounce_off()
	SoundManager.play_sfx(SoundManager.stomp, player)

func damage(direction := 1) -> void:
	if hurt:
		return
	can_throw_ball = false
	hurt = true
	SoundManager.play_sfx(SoundManager.stun, self)
	velocity.x = 500 * get_floor_normal().x
	animations.play("Hurt")
	await get_tree().create_timer(0.25, false).timeout
	animations.play("Idle")
	if is_on_floor():
		velocity.x = 0
	hurt = false

func _on_timer_timeout() -> void:
	ball()
