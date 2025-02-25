extends Node2D

@onready var mushroom_scene = preload("res://Instances/Prefabs/Items/mushroom_item.tscn")
const BLOCK_COIN = preload("res://Instances/Parts/block_coin.tscn")
var mushroom_if_small := true

@onready var mario = GameManager.player
var amount := 1
var can_dispense := true

func _ready() -> void:
	if get_parent() is Block:
		mushroom_if_small = get_parent().mushroom_if_small

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
	if get_parent().player != null:
		get_parent().player.ground_pound_land_timer = 0.5
	var node = BLOCK_COIN.instantiate()
	GameManager.current_level.add_child(node)
	node.global_position = global_position
	SoundManager.play_sfx(SoundManager.coin, self)
	await get_tree().create_timer(0.25, false).timeout
	can_dispense = true

func dispense_item(item: PackedScene, launch := false, launch_velocity := Vector2.ZERO) -> void:
	var item_node = item.instantiate()
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
