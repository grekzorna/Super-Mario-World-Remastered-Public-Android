extends PowerUpSpriteExtra

@onready var fall_sfx: AudioStreamPlayer2D = $FallSFX
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if animation_player.has_animation(player.sprite.animation):
		animation_player.play(player.sprite.animation)
		animation_player.seek(player.sprite.frame)
