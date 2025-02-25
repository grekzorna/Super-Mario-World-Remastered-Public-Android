extends Enemy

@onready var sprite_animations: AnimationPlayer = $Sprite/SpriteAnimations
const SPIKE_BALL = preload("res://Instances/Prefabs/Interactables/SpikeProjectileBall.tscn")
var wave := 0.0
@onready var starting_position = global_position
var target_player: Player = null
var moving := true

func _physics_process(delta: float) -> void:
	if moving:
		wave += 8 * delta
	global_position.x = starting_position.x + sin(wave) * 2
	target_player = CoopManager.get_closest_player(global_position)
	direction = sign(target_player.global_position.x - global_position.x)
	sprite.scale.x = direction
	wave = wrap(wave, 0, 2 * PI)

func damage() -> void:
	die()

func play_throw_animation() -> void:
	moving = false
	sprite_animations.play("GetBall")

func throw_ball() -> void:
	summon_ball()
	await sprite_animations.animation_finished
	sprite_animations.play("Idle")
	moving = true
	$Timer.start()

func summon_ball() -> void:
	var ball = SPIKE_BALL.instantiate()
	ball.velocity = Vector2(100 * direction, -100)
	ball.global_position = $SpikeBall.global_position
	SoundManager.play_sfx("res://Assets/Audio/SFX/hammer-bro-throw.wav", self)
	add_sibling(ball)
