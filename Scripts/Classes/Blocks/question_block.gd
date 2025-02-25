@icon("res://Assets/Sprites/Editor/Icons/QuestionBlock.png")
class_name QuestionBlock
extends Block

@export var only_if_star := false

var invisible := false

func spawn() -> void:
	collision.set_deferred("disabled", not visible)
	if not visible:
		show()
		invisible = true
		visuals.self_modulate.a = 0
	

func block_hit_override(direction := "Up") -> void:
	show()
	if can_hit == false:
		return
	if only_if_star:
		if player.is_star == false:
			item = null
	if item != null:
		if direction == "Up":
			summon_item(item)
		else:
			summon_item_down(item)
		can_hit = false
		empty_block()
	else:
		dispense_coin()
		coin_amount -= 1
		if is_instance_valid(player):
			player.ground_pound_land_timer = 0.5
		if coin_amount <= 0:
			empty_block()
			can_hit = false

func _on_invisible_detect_area_entered(area: Area2D) -> void:
	if not invisible:
		return
	if can_hit == false:
		return
	if area.get_parent() is Player:
		if area.get_parent().velocity.y < 0:
			collision.set_deferred("disabled", false)
			show()
			visuals.modulate.a = 1
			block_hit("Up")
			visuals.position.y = 0
			if area.get_parent().carried:
				area.get_parent().carrying_player.global_position.y += 2
			else:
				area.get_parent().global_position.y += 2
			await get_tree().physics_frame
			invisible = false
