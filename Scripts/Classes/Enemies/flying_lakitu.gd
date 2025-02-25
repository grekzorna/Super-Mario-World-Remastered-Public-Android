extends Enemy

var target_player: Player = null
@onready var starting_position := global_position
@export var attack_item: PackedScene = null
@export var has_1_up := true
@onready var _1_up: CharacterBody2D = $"1Up"
@onready var animations: AnimationPlayer = $Animations
@export var fishing_item: Node2D
const EMPTY_LAKITU_CLOUD = preload("res://Instances/Prefabs/Interactables/empty_lakitu_cloud.tscn")
var attacking := false

@export var friendly := false

var can_summon := true
var wave_speed := 4
var wave_amount := 16
var wave_prog := 0.0

var move_speed := 100
var fly_direction := 1

var velocity_direction := 1

func spawn() -> void:
	if is_instance_valid(_1_up):
		_1_up.show()
		if has_1_up == false:
			_1_up.queue_free()
	timer.start(randi_range(3, 8))
	if SettingsManager.sprite_settings.lakitucloud == 0:
		$Cloud.queue_free()
		$OldCloud.show()
	else:
		$OldCloud.queue_free()
		$Cloud.show()

func _physics_process(delta: float) -> void:
	attacking = is_instance_valid(_1_up) == false
	if velocity.x > 0:
		velocity_direction = 1
	else:
		velocity_direction = -1
	target_player = CoopManager.get_closest_player(global_position)
	if is_instance_valid(fishing_item):
		fishing_item.position.x = abs(fishing_item.position.x) * velocity_direction
		fishing_item.scale.x = -velocity_direction
	$Sprite.scale.x = velocity_direction
	wave_prog += wave_speed * delta
	global_position.y = starting_position.y + sin(wave_prog) * wave_amount
	if is_instance_valid(target_player):
		var target_speed = move_speed + (global_position.distance_to(Vector2(target_player.global_position.x, global_position.y)))
		velocity.x = lerpf(velocity.x, target_speed * fly_direction, delta / 1.1)
		if global_position.x > target_player.global_position.x:
			fly_direction = -1
		else:
			fly_direction = 1
	move_and_slide()

func damage() -> void:
	die()
func melee_damage() -> void:
	die()

@onready var timer: Timer = $Timer

func summon_cloud() -> void:
	if can_summon == false:
		return
	can_summon = false
	var node = EMPTY_LAKITU_CLOUD.instantiate()
	node.global_position = global_position
	add_sibling(node)

func _on_timer_timeout() -> void:
	timer.start(randi_range(3, 8))
	if attacking == false or friendly:
		return
	animations.play("ThrowShell")
	await animations.animation_finished
	animations.play("Idle")

func player_hit_fire(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()

func throw_item() -> void:
	SoundManager.play_sfx("res://Assets/Audio/SFX/hammer-bro-throw.wav", self)
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
	var node = attack_item.instantiate()
	var throw_direction := 1
	node.global_position = global_position
	if target_player.global_position.x < global_position.x:
		throw_direction = -1
	if node is Enemy or node is HeldObject:
		node.direction = throw_direction
	if node is CharacterBody2D:
		node.velocity.x = 150 * throw_direction
		node.velocity.y = -250
	GameManager.current_level.add_child(node)
