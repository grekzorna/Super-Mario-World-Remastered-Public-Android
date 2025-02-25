class_name SpriteParticle
extends AnimatedSprite2D

func _ready() -> void:
	await animation_finished
	queue_free()
