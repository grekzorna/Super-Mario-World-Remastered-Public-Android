extends Block

@onready var item_sprite: Sprite2D = $Casing/PowerUp/Item
const ROULETTE_BLOCK_ITEM = preload("res://Instances/Prefabs/Items/roulette_block_item.tscn")
var item_selection := 0

func block_hit_override(direction := "") -> void:
	if can_hit == false:
		return
	$RouletteBlockItem.queue_free()
	summon_item(ROULETTE_BLOCK_ITEM)
	can_hit = false
