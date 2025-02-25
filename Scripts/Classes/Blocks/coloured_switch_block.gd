class_name ColourSwitchBlock
extends Block

@export_enum("Yellow", "Green", "Blue", "Red") var colour := 0
@onready var sprite: Sprite2D = $Sprite

@onready var powerups = [preload("res://Instances/Prefabs/Items/mushroom_item.tscn"), preload("res://Instances/Prefabs/Items/cape_feather.tscn"), null, null]

func spawn() -> void:
	sprite.frame = colour
	item = powerups[colour]
	if colour > 1:
		can_hit = false

func block_hit_override(direction := "Up") -> void:
	if can_hit == false:
		return
	if item != null:
		summon_item(item)
		empty_block()
	else:
		dispense_coin()
		coin_amount -= 1
		if coin_amount <= 0:
			empty_block()
