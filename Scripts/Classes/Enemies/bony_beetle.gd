extends Enemy

var moving := true
@onready var ledge_detection: RayCast2D = $LedgeDetection
@onready var hitbox: Area2D = $Hitbox

var can_hit := true

var crumbled := false

const MOVE_SPEED := 25
@onready var animations: AnimationPlayer = $Sprite/Animations

func _physics_process(delta: float) -> void:
	if moving:
		velocity.x = MOVE_SPEED * direction
	else:
		velocity.x = 0
	ledge_detection.position.x = 4 * direction
	sprite.scale.x = -direction
	velocity.y += 15
	if is_on_wall():
		flip_direction()
	if ledge_detection.is_colliding() == false:
		if is_on_floor():
			flip_direction()
	move_and_slide()

func melee_damage() -> void:
	die()

func damage() -> void:
	if not moving:
		return
	crumble()

func spike_hide() -> void:
	if crumbled:
		return
	moving = false
	sprite.play("Hide")
	await sprite.animation_finished
	spiky_top = true
	await get_tree().create_timer(2, false).timeout
	sprite.play("Show")
	await sprite.animation_finished
	spiky_top = false
	moving = true
	sprite.play("Walk")

func flip_direction() -> void:
	if can_hit:
		can_hit = false
	else:
		return
	direction *= -1
	await get_tree().create_timer(0.1, false).timeout
	can_hit = true

func crumble() -> void:
	if moving:
		moving = false
	else:
		return
	spiky_top = false
	crumbled = true
	hitbox.set_deferred("monitorable", false)
	$Hitbox/Shape.set_deferred("disabled", true)
	SoundManager.play_sfx(SoundManager.bone_crumble, self)
	sprite.play("Crumble")
	await get_tree().create_timer(4, false).timeout
	animations.play("Shake")
	await get_tree().create_timer(1, false).timeout
	sprite.play("Reassemble")
	animations.play("RESET")
	await sprite.animation_finished
	moving = true
	sprite.play("Walk")
	$Hitbox/Shape.set_deferred("disabled", false)
	hitbox.set_deferred("monitorable", true)
	crumbled = false
