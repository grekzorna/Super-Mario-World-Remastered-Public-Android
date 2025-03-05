extends Node2D

@onready var blocks := [$BlockA, $BlockB, $BlockC]
const _1_UP = preload("res://Instances/Prefabs/Items/1_up.tscn")

var idx := 0

func block_hit(block: Block) -> void:
	print(block.can_hit)
	if block.can_hit == false:
		return
	if randf_range(0, 10) < 6.5 or idx == 2:
		if idx >= 2:
			block.dispense_item(_1_UP)
			SoundManager.play_sfx(SoundManager.item_sprout, block)
		else:
			block.dispense_coin()
		idx += 1
		block.visuals.play("Correct")
		block.can_hit = false
	else:
		block.can_hit = false
		SoundManager.play_sfx(SoundManager.wrong, self)
		null_blocks()

func _on_block_a_block_hitted() -> void:
	block_hit(blocks[0])

func null_blocks() -> void:
	for i in blocks:
		if i.visuals.animation != "Correct":
			i.visuals.play("Wrong")
		i.can_hit = false

func _on_block_b_block_hitted() -> void:
	block_hit(blocks[1])


func _on_block_c_block_hitted() -> void:
	block_hit(blocks[2])
