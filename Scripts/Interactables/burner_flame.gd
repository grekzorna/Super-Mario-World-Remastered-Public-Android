extends StaticBody2D


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()

func play_sound() -> void:
	SoundManager.play_sfx(preload("res://Assets/Audio/SFX/flames.wav"), self)
