class_name RedCoin
extends Node2D

var active := false

signal collected

func _process(delta: float) -> void:
	visible = active


func _on_hitbox_area_entered(area: Area2D) -> void:
	if not active:
		return
	if area.get_parent() is Player:
		if GameManager.red_coins_collected < 8:
			SoundManager.play_sfx(SoundManager.red_coin_collect, self, 1 + (float(GameManager.red_coins_collected) * 0.05))
		GameManager.add_red_coin()
		collected.emit()
		queue_free()
