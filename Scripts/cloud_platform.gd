extends StaticBody2D

var player: Player = null

func _ready() -> void:
	scale = Vector2.ZERO
	enter_animation()
	await get_tree().create_timer(5, false).timeout
	exit_animation()
	player.cloud_platforms_left += 1
	await get_tree().create_timer(0.1, false).timeout
	queue_free()

func enter_animation() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)

func exit_animation() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
