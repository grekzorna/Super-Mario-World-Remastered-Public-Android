class_name BoomBoomBoss
extends CharacterBody2D

@export var spiky := false
@export var spiky_head := false
@onready var states: StateMachine = $States
@onready var animations: AnimationPlayer = $Animations
@onready var sprite: Sprite2D = $Sprite
@onready var skid_particles: GPUParticles2D = $Skid
@onready var swing_sfx: AudioStreamPlayer2D = $SwingSFX
@onready var puff_trail: GPUParticles2D = $PuffTrail

@export var health := 3
var flying := false
var direction := -1

var run_speed := 200
var run_accel := 1
var fly_speed := 250
var fly_accel := 0.5

func _physics_process(delta: float) -> void:
	sprite.scale.x = abs(sprite.scale.x) * -direction
	move_and_slide()

func play_stomp_effect() -> void:
	SoundManager.play_sfx(SoundManager.bullet, self)
	ParticleManager.summon_particle(ParticleManager.GROUND_POUND_IMPACT, global_position)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if states.state.name == "Hurt":
		return
	if area.get_parent() is Player:
		var player: Player = area.get_parent()
		if player.global_position.y < global_position.y - 8 and player.velocity.y > 0 and player.is_on_floor() == false:
			if spiky_head or spiky:
				if player.spinning:
					player.spiky_jump()
					return
				else:
					player.damage()
					return
			player.bounce_off()
			damage()
		else:
			player.damage()
	if area.get_parent() is LavaArea:
		lava_enter()

func damage() -> void:
	health -= 1
	states.transition_to("Hurt")
	SoundManager.play_sfx(SoundManager.stomp, self)
	SoundManager.play_sfx(SoundManager.stun, self)

func lava_enter() -> void:
	if states.state.name != "LavaHurt":
		health -= 2
		SoundManager.play_sfx(SoundManager.boss_flame, self)
		SoundManager.play_sfx(SoundManager.boss_burn, self)
	states.transition_to("LavaHurt")
