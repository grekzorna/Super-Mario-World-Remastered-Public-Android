class_name BowserBoss
extends CharacterBody2D

var health := 6
var phase := 1
@export var screen_center := Vector2(176, -96)
@onready var animations: AnimationPlayer = $Animations
var mecha_koopa_amount := 0
var throw_direction := 1
@onready var bowser_sprite: AnimatedSprite2D = $Visuals/Bowser
@onready var clown_car: Node2D = $Visuals/ClownCar
@onready var state_machine: StateMachine = $States
@onready var clown_car_animations: AnimationPlayer = $Visuals/ClownCar/Animations
@onready var visuals: Node2D = $Visuals
@onready var clown_car_eyes: AnimatedSprite2D = $Visuals/ClownCar/Eyes
@onready var defeat_particles: AnimatedSprite2D = $Visuals/DefeatParticles
@onready var attack_timer: Timer = $AttackTimer

var cutscene := false
static var seen_intro := false
var can_hurt := true
const MECHA_KOOPA_SCENE = preload("res://Instances/Prefabs/Enemies/mecha_koopa.tscn")

signal fire_start

signal dead

func bowser_hitbox_hit(area: Area2D) -> void:
	if cutscene:
		return
	if area.get_parent() is HeldObject:
		damage()
		area.get_parent().die()
	elif area.get_parent() is Player:
		if area.get_parent().spinning:
			damage()
			area.get_parent().spin_bounce_off()
		else:
			area.get_parent().damage()

func clown_car_hit(area: Area2D) -> void:
	if cutscene:
		return
	if area.get_parent() is HeldObject:
		area.get_parent().die()
	elif area.get_parent() is Player:
		area.get_parent().play_sfx("bump")
		area.get_parent().velocity = clown_car.global_position.direction_to(area.get_parent().global_position) * 350

func propeller_hit(area: Area2D) -> void:
	if cutscene:
		return
	if area.get_parent() is HeldObject:
		area.get_parent().die()
	elif area.get_parent() is Player:
		area.get_parent().damage()

func return_to_attack() -> void:
	cutscene = false
	can_hurt = true
	match phase:
		1:
			state_machine.transition_to("AttackIdle1")
		2:
			state_machine.transition_to("AttackIdle2")
		3:
			state_machine.transition_to("AttackIdle3")
		4:
			state_machine.transition_to("Death")

func get_mecha_koopas() -> int:
	var amount := 0
	for i in get_parent().get_children():
		if i is MechaKoopa:
			amount += 1
		elif i is HeldObject:
			amount += 1
	return amount

var throw_index := 1

func spawn_mecha_koopa() -> void:
	var target_player: Player = CoopManager.get_closest_player(global_position)
	if target_player.global_position > global_position:
		throw_direction = -1
	else:
		throw_direction = 1
	throw_index *= -1
	var node = MECHA_KOOPA_SCENE.instantiate()
	node.global_position = global_position - Vector2(16 * throw_index, 16)
	node.velocity.y = -200
	node.direction = -throw_direction
	node.velocity.x = 50 * -throw_index
	add_sibling(node)

func _process(delta: float) -> void:
	if OS.is_debug_build():
		if Input.is_action_just_pressed("debug_clear"):
			health = 0
			damage()
		if Input.is_action_just_pressed("debug_secret"):
			health = 3
			phase = 2
			damage()

func do_attack() -> void:
	if phase == 1:
		state_machine.transition_to("MechaDrop")
	else:
		if randi_range(1, 4) != 1:
			state_machine.transition_to("MechaDrop")
		else:
			state_machine.transition_to("SteelyDrop")

func damage() -> void:
	if can_hurt == false:
		return
	if state_machine.state.name == "Hurt":
		return
	if cutscene:
		return
	SoundManager.play_sfx(SoundManager.stun, self)
	health -= 1
	if health % 2 == 0:
		phase += 1
	state_machine.transition_to("Hurt")

func remove_mecha_koopas() -> void:
	for i in GameManager.current_level.get_children():
		if i is HeldObject or i is Enemy:
			ParticleManager.summon_particle(ParticleManager.PUFF_SPR, i.global_position - Vector2(0, 8))
			i.queue_free()
