extends CharacterBody2D

var direction := 1
var health := 3
var move_speed := 15

var target_player: Player = null
@onready var animations: AnimationPlayer = $Animations

var positions := {-1: 256, 1: 112}

var target_direction := -1

signal defeated

var chasing := false
var dead := false

func _ready() -> void:
	await get_tree().create_timer(1, false).timeout
	animations.play("Appear")
	await animations.animation_finished
	chasing = true

func _physics_process(delta: float) -> void:
	if chasing:
		handle_chasing(delta)
	elif dead:
		velocity.y += 15
	move_and_slide()

func handle_chasing(delta: float) -> void:
	animations.play("Idle")
	target_player = CoopManager.get_closest_player(global_position)
	$Sprite.scale.x = direction
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
	velocity = lerp(velocity, move_speed * global_position.direction_to(target_player.global_position), delta * 2)

func retreat() -> void:
	target_direction *= -1
	var target_position := Vector2.ZERO
	target_position.x = positions[target_direction]
	target_position.y = [-112, -48].pick_random()
	animations.play_backwards("Appear")
	await animations.animation_finished
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 2)
	await tween.finished
	animations.play("Turn")
	await animations.animation_finished
	animations.play("Appear")
	await animations.animation_finished
	chasing = true

func hurt() -> void:
	SoundManager.play_sfx(SoundManager.stun, self)
	animations.play("Hurt")
	health -= 1
	chasing = false
	velocity = Vector2.ZERO
	await animations.animation_finished
	if health <= 0:
		die()
	else:
		retreat()

func die() -> void:
	defeated.emit()
	SoundManager.play_sfx(SoundManager.boss_fall, self)
	velocity.y = -200
	dead = true
	await get_tree().create_timer(2, false).timeout
	CoopManager.boss_defeated("", true)


func hitbox_hit(area: Area2D) -> void:
	if not chasing:
		return
	if area.get_parent() is Player:
		area.get_parent().damage()
	elif area.get_parent() is HeldObject:
		area.get_parent().die()
		hurt()
