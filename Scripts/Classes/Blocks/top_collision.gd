extends Node2D

signal block_hit
signal ground_pounded

signal spin_jumped
@onready var area_2d: Area2D = $Area2D

var player: Player = null

func _process(delta: float) -> void:
	if area_2d.get_overlapping_areas().any(is_player):
		get_parent().player = player
		if player.ground_pounding:
			emit_signal("block_hit", "Down")
			if player.power_state.hitbox_size == "Regular":
				emit_signal("ground_pounded")
		elif player.spinning and player.velocity.y > 0 and not player.spin_free and player.power_state.hitbox_size == "Regular":
			player.spin_free = !Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id))
			emit_signal("spin_jumped")

func is_player(area: Area2D) -> bool:
	if area.get_parent() is Player:
		get_parent().player = area.get_parent()
		player = area.get_parent()
	return area.get_parent() is Player


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		pass
