extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var player_detect: RayCast2D = $PlayerDetect
@onready var animations: AnimationPlayer = $Animations

@export var alt_sprite_frames: SpriteFrames = null

var direction_vector := Vector2.LEFT
var move_speed := 75

var falling := false

var hori_direction := 1

signal damaged

@export var health := 3
const gravity := 15

var hurt := false

signal defeated

@export var can_change_direction := false

var can_land := false

func _physics_process(delta: float) -> void:
	sprite.flip_h = hori_direction == -1
	if not falling and not hurt:
		velocity = direction_vector * move_speed
		sprite.rotation = lerp_angle(sprite.rotation, (velocity * -hori_direction).angle(), delta * 5)
		velocity += gravity * direction_vector.rotated(deg_to_rad(90 * -hori_direction))
		sprite.play("Walk")
	elif not hurt:
		velocity.x = 0
		velocity.y += gravity
		if is_on_floor() and can_land:
			can_land = false
			SoundManager.play_sfx(SoundManager.bullet, self)
			await get_tree().create_timer(1, false).timeout
			falling = false
			if can_change_direction:
				if randi_range(0, 1) == 0:
					direction_vector = Vector2.RIGHT
					hori_direction = -1
				else:
					hori_direction = -1
					direction_vector = Vector2.RIGHT
			else:
				hori_direction = 1
				direction_vector = Vector2.LEFT
		
	if is_on_wall():
		direction_vector = Vector2.UP
	if is_on_ceiling():
		if player_detect.is_colliding():
			if player_detect.get_collider() is Player:
				fall()
		direction_vector = Vector2.RIGHT * hori_direction
	
	move_and_slide()


func fall() -> void:
	falling = true
	can_land = true
	animations.play("Fall")

func damage() -> void:
	move_speed += 25
	velocity = Vector2.ZERO
	SoundManager.play_sfx(SoundManager.stun, self)
	SoundManager.play_sfx(SoundManager.stomp, self)
	hurt = true
	health -= 1
	animations.play("Hit")
	await get_tree().create_timer(1, false).timeout
	if health <= 0:
		die()
		return
	await get_tree().create_timer(1, false).timeout
	damaged.emit()
	falling = false
	hurt = false

func summon_puff() -> void:
	$Puff.play("default")
	SoundManager.play_sfx("res://Assets/Audio/SFX/boss-poof.wav", self)

func die() -> void:
	SoundManager.play_sfx(SoundManager.boss_defeat, self)
	animations.play("Die")
	await get_tree().create_timer(2.5, false).timeout
	emit_signal("defeated")
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if hurt:
		return
	if area.get_parent() is Player:
		var player = area.get_parent()
		if player.global_position.y < global_position.y - 16 and player.velocity.y > 0 and is_on_floor():
			damage()
			player.bounce_off()
		else:
			player.damage()
