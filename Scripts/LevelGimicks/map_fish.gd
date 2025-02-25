extends Node2D

func play_animation() -> void:
	$Animation.play("JumpUp")
	SoundManager.play_sfx(SoundManager.swim, self)
