@icon("res://Assets/Sprites/Editor/Icons/SpinBlock.png")
class_name SpinBlock
extends Block
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $Sprite/AnimationPlayer
@onready var area_2d: Area2D = $Area2D

const COIN = ("res://Instances/Prefabs/Items/coin.tscn")
var hit := false

func spawn() -> void:
	p_switch = item == null
	spin_jumped.connect(launch_player)
	if item == null:
		ground_pounded.connect(shatter)

func launch_player() -> void:
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) or Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		player.velocity.y = -200
	else:
		player.velocity.y = -150
	player.spinning = true
	shatter()

func spin() -> void:
	var node = load("res://Instances/Prefabs/Blocks/spinning_spin_block.tscn").instantiate()
	node.global_position = global_position
	add_sibling(node)
	queue_free()

func block_hit_override(direction := "Up") -> void:
	if item:
		if item.resource_path == COIN or coin_amount != 0:
			dispense_coin()
			coin_amount -= 1
			GameManager.coins += 1
			GameManager.score += 100
			if coin_amount <= 0:
				empty_block()
		else:
			summon_item(item)
			empty_block()
	else:
		for i in 4:
			await get_tree().physics_frame
		spin()

func _on_area_2d_2_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		if player.spin_jumping and player.power_state.hitbox_size == "Regular" and item == null and player.velocity.y > 0:
			spin_jumped.emit()
		elif player.ground_pounding and player.state_machine.state.name == "PropellerFly" and item == null:
			player.ground_pound_land_timer += 1.0
			ground_pounded.emit()
