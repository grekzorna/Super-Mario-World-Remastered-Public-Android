@icon("res://Assets/Sprites/Editor/Icons/Enemy.png")
class_name Enemy
extends CharacterBody2D
@onready var gib = preload("res://Instances/Parts/enemy_gib.tscn")
@onready var flash = preload("res://Instances/Parts/flash_particle.tscn")
@onready var sprite = get_node_or_null("Sprite")
@export var enemy_height := 16
@onready var spawn_pos := global_position
@export_enum("Swallow", "Spit", "None") var yoshi_behavior := "None"
@export_enum("Spin", "Drop", "Poof") var gib_type := 0
@export var ice_size := Vector2.ONE
@export var ice_offset := Vector2.ZERO
@export var main_animation_player: AnimationPlayer = null ## Used by ice blocks, when needing to freeze an animation.
@export var spit_item: PackedScene = null
@export var can_jump_on := true
@export var can_swim := false
@export var water_fall_speed := 50
@export var water_move_speed := 50
@export var spiky_top := false
@export var can_lava_swim := false
@export var can_slide_damage := true
@export var kickable := false ## Dictate if the enemy will be kicked and killed by the player. Useful for cheep cheeps out of water and sliding koopas.
@export var player_bounce_off := true
@export var can_silver_switch := true
@export var can_cape_damage := true
@export var can_spin_kill := true
@export var can_held_item_damage := true
@export var can_ground_pound := true
@export var can_fire_damage := true
@export var can_ice_freeze := true
@onready var player: Player = null

@export var z_index_dependant := false


var yoshi: Yoshi = null
var is_yoshi_item := false
var direction := -1
var can_damage = true
var can_add_score := true
var can_stomp_on := true
var can_hurt := true
var frozen := false
const PHYSICS_COIN = preload("res://Instances/Prefabs/Items/physics_coin.tscn")

var yoshi_player: Player = null

signal jumped_on
signal killed

func _enter_tree() -> void:
	disable_mode = CollisionObject2D.DISABLE_MODE_MAKE_STATIC
	for i in get_children():
		if i is VisibleOnScreenEnabler2D or i is VisibleOnScreenNotifier2D:
			i.screen_exited.connect(off_screen)
	

func _ready() -> void:
	disable_mode = CollisionObject2D.DISABLE_MODE_MAKE_STATIC
	spawn()
	await get_tree().physics_frame
	if is_instance_valid(GameManager.player):
		player = GameManager.player

func spawn() -> void:
	pass

func check_hit(_area: Area2D) -> void:
	pass

func player_bounce(combo := true) -> void:
	pass

func go_to_spawn_pos() -> void:
	global_position = spawn_pos

func damage() -> void:
	pass

func freeze() -> void:
	if frozen:
		return
	var node = load("res://Instances/Prefabs/Interactables/ice_block.tscn").instantiate()
	node.global_position = global_position
	node.size = ice_size
	node.frozen_target = self
	if is_instance_valid(main_animation_player):
		main_animation_player.stop()
		main_animation_player.play("RESET")
	frozen = true
	can_hurt = false
	if sprite is AnimatedSprite2D:
		sprite.stop()
	can_damage = false
	GameManager.current_level.add_child(node)
	SoundManager.play_sfx(SoundManager.kick, self, 1.4)
	on_freeze()

func damage_player(player_to_damage: Player) -> void:
	player_to_damage.damage()

func on_yoshi_tongue_grab() -> void:
	pass

func melee_attack() -> void:
	if player != null:
		player.play_sfx("kick")
	else:
		SoundManager.play_sfx(SoundManager.kick, self)
	die()

func coin_die(auto_collect := false) -> void:
	killed.emit()
	summon_coin(auto_collect)
	ParticleManager.summon_particle(ParticleManager.PUFF, global_position)
	queue_free()

func summon_coin(auto_collect := false) -> void:
	var node = PHYSICS_COIN.instantiate()
	node.global_position = global_position
	node.auto_collect = auto_collect
	add_sibling(node)
	node.velocity.y = -100

func on_freeze() -> void:
	pass

func destroy_object(object) -> void:
	if object.held:
		object.player.holding = false
	object.summon_gib()
	object.queue_free()

func spin_die(_is_yoshi := false) -> void:
	SoundManager.play_sfx(SoundManager.super_stomp, self)
	GameManager.add_score(400, true, global_position)
	ParticleManager.summon_particle(ParticleManager.SPIN_IMPACT, global_position - Vector2(0, enemy_height))
	queue_free()
	return

func ground_pound_die() -> void:
	SoundManager.play_sfx(SoundManager.super_stomp, self)
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
	GameManager.add_score(400, true, global_position)
	queue_free()
	return

func die(_add_score := true) -> void:
	killed.emit()
	summon_gib()
	queue_free()

func death_animation() -> void:
	return

func summon_gib() -> void:
	await death_animation()
	var gib_node = gib.instantiate()
	if is_instance_valid(sprite):
		gib_node.sprite = sprite.duplicate()
		if gib_node.sprite.get_child(0) is AnimationPlayer:
			gib_node.sprite.get_child(0).queue_free()
	gib_node.global_position = global_position
	gib_node.direction = direction
	gib_node.type = gib_type
	gib_node.z_index = z_index
	GameManager.current_level.add_child(gib_node)

func summon_flash_particle() -> void:
	var node = flash.instantiate()
	node.global_position = player.global_position
	get_parent().add_child(node)

func off_screen() -> void:
	if global_position.y > 48:
		queue_free()
