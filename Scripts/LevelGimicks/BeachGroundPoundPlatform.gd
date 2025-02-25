extends Node2D


var can_hit := true
var hits := 0
@onready var ground_pound_area_2: Node2D = $GroundPoundArea2

@onready var coin_resource = preload("res://Resources/CrystalCoins/Beach1/2.tres")

func _on_ground_pound_area_2_activated() -> void:
	if can_hit == false or hits >= 8:
		return
	hits += 1
	can_hit = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "global_position", Vector2(global_position.x, global_position.y + 16), 0.25)
	await get_tree().create_timer(0.5).timeout
	can_hit = true
	if hits == 8:
		ground_pound_area_2.spawn_coin(get_parent().get_parent(), coin_resource)
