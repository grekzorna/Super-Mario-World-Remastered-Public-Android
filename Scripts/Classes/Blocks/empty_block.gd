class_name EmptyBlock
extends Block

var block_owner: Block = null

func _ready() -> void:
	if p_switch:
		return
	await get_tree().physics_frame
	if GameManager.current_level.p_switch_active:
		GameManager.current_level.spawn_coin(global_position)
		queue_free()
