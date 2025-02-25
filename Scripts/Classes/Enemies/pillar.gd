extends Node2D

@export var offset := false

func _ready() -> void:
	if offset:
		$AnimationPlayer.stop()
		await get_tree().create_timer(2.5, false).timeout
		$AnimationPlayer.play("Loop")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()

func play_impact() -> void:
	SoundManager.play_sfx(SoundManager.bullet, self)
	GameManager.shake_camera(5)
