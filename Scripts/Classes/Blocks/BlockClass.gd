@icon("res://Assets/Sprites/Editor/Icons/Block.png")
class_name Block
extends AnimatableBody2D

@export var mushroom_if_small := false
@export var visuals: Node = null
@export var p_switch := false
@export var enable_side_hits := true
@export var enable_ground_pounds := true
@onready var block_animation_scene = preload("res://Instances/Parts/BlockParts/block_animations.tscn")
@export var item: PackedScene = null
@export var item_property_override := {}
@export var coin_amount := 1
const BLOCK_COIN = preload("res://Instances/Parts/block_coin.tscn")
const BLOCK_BREAK = preload("res://Assets/Sprites/Particles/BlockBreak.png")
var can_hit := true
const mushroom_scene = preload("res://Instances/Prefabs/Items/mushroom_item.tscn")
var can_dispense := true

@onready var empty_block_scene = ("res://Instances/Prefabs/Blocks/empty_block.tscn")
var item_dispenser: Node2D = null

signal block_hitted
signal spin_jumped 
signal ground_pounded
@onready var collision: CollisionShape2D = get_node_or_null("Collision")
var player: Player = null
var block_animations
var can_check_collision := true

var empty

var can_bounce := false

func _ready() -> void:
	sync_to_physics = false
	z_index = 0
	block_animations = block_animation_scene.instantiate()
	add_child(block_animations)
	physics_interpolation_mode = PHYSICS_INTERPOLATION_MODE_OFF
	spawn()
	for i in [1, 3, 9]:
		set_collision_layer_value(9, true)
	for i in [1, 2, 3, 4, 5, 6, 7, 8]:
		set_collision_mask_value(i, false)
	for i in [2, 4, 5]:
		set_collision_mask_value(i, true)

func _process(delta: float) -> void:
	update(delta)
	if visuals != null and block_animations != null:
		if collision != null:
			collision.global_position = block_animations.global_position
		if visuals != null:
			visuals.global_position = block_animations.global_position

func _physics_process(delta: float) -> void:
	if can_bounce:
		set_collision_mask_value(9, false)
		var collision = move_and_collide(Vector2.UP * 2, true, 0)
		if is_instance_valid(collision):
			bounce_node(collision.get_collider())
	physics_update(delta)

func physics_update(delta: float) -> void:
	pass

func spawn() -> void:
	pass

func block_hit(direction: String) -> void:
	if can_hit == false:
		return
	if is_instance_valid(block_animations) == false:
		return
	var animations = block_animations.get_node("AnimationPlayer")
	emit_signal("block_hitted")
	block_hit_override()
	match direction:
		"Up":
			animations.play("BottomHit")
			bounce()
		"Down":
			animations.play("TopHit")
		"Left":
			animations.play("RightHit")
		"Right":
			animations.play("LeftHit")
	return

func bounce_node(node: Node) -> void:
	if node is Enemy:
		node.melee_attack()
	if node is PowerUp:
		node.static_movement = false
		node.set_physics_process(true)
		node.set_process(true)
		node.velocity.y = -250
	if node is HeldObject:
		node.velocity.y = -250

func empty_block() -> void:
	can_hit = false
	empty = true
	var node = load(empty_block_scene).instantiate()
	await get_tree().create_timer(0.1, false).timeout
	node.block_owner = self
	node.global_position = global_position
	node.p_switch = false
	add_sibling(node)
	await get_tree().physics_frame
	node.global_position = global_position
	hide()
	global_position = Vector2(-0, 1000) # Send them to the void, since if we delete them, they will just vanish when reloading the saved level.

func block_hit_override(direction := "Up") -> void:
	pass

func bounce() -> void:
	can_bounce = true
	for i in 4:
		await get_tree().physics_frame
	can_bounce = false

func update(delta: float) -> void:
	pass
	
var amount := 0

func summon_item(item: PackedScene, instant := false) -> void:
	if can_dispense == false:
		return
	can_dispense = false
	await get_tree().create_timer(0.09, false).timeout
	amount = 0
	SoundManager.play_sfx(SoundManager.item_sprout, self)

	for i in CoopManager.active_players.values():
		if is_instance_valid(i) == false:
			break
		var angle = randi_range(-60, 60)
		var launch_vel = Vector2.UP.rotated((angle)) * 200
		amount += 1
		print(launch_vel)
		if i.power_state == i.small_power_state and mushroom_if_small and item.instantiate() is PowerUp:
			dispense_item(mushroom_scene, CoopManager.players_connected > 1, launch_vel)
		else:
			dispense_item(item, CoopManager.players_connected > 1, launch_vel)
		if item.instantiate() is PowerUp == false:
			return

func summon_item_down(item: PackedScene) -> void:
	pass

func dispense_coin() -> void:
	if can_dispense == false:
		return
	can_dispense = false
	var node = BLOCK_COIN.instantiate()
	node.global_position = global_position
	GameManager.current_level.add_child(node)
	SoundManager.play_sfx(SoundManager.coin, self)
	await get_tree().create_timer(0.25, false).timeout
	can_dispense = true

func dispense_item(item: PackedScene, launch := false, launch_velocity := Vector2.ZERO) -> void:
	var item_node = item.instantiate()
	for i in item_property_override.keys():
		item_node.set(i, item_property_override[i])
	item_node.global_position = global_position
	if launch and item_node is PowerUp:
		item_node.global_position.y -= 16
		item_node.velocity = launch_velocity
	elif item_node is CharacterBody2D and launch:
		item_node.global_position = global_position - Vector2(0, 0)
		item_node.velocity.y = -150
	else:
		item_node.global_position = global_position
		if item_node is PowerUp == false:
			item_node.global_position.y -= 4
			if item_node is CharacterBody2D:
				item_node.velocity.y = -150
	if item_node is PowerUp and launch:
		if amount % 2 == 0:
			item_node.direction = -1
		else:
			item_node.direction = 1
	GameManager.current_level.add_child(item_node)
	if item_node is PowerUp and launch == false:
		item_node.block_spawn()

func on_ground_pound(player: Player) -> void:
	if can_hit == false or enable_ground_pounds == false:
		return
	print("HIIIIIII")
	await get_tree().process_frame
	can_hit = false
	await get_tree().create_timer(0.25, false).timeout
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)):
		player.ground_pound_land_timer = 0.5
	else:
		player.ground_pound_land_timer = 0
	await get_tree().physics_frame
	await get_tree().physics_frame
	

func spawn_empty() -> void:
	var node = load(empty_block_scene).instantiate()
	node.global_position = global_position
	visuals.self_modulate.a = 0
	GameManager.current_level.add_child(node)

func shatter() -> void:
	if player != null:
		player.play_sfx("shatter")
	else:
		SoundManager.play_sfx(SoundManager.shatter, self)
	ParticleManager.summon_four_part([BLOCK_BREAK, BLOCK_BREAK, BLOCK_BREAK, BLOCK_BREAK], global_position)
	queue_free()
