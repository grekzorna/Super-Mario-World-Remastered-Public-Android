extends PowerUpSpriteExtra
@onready var sfx: AudioStreamPlayer = $SFX
@onready var bar: TextureProgressBar = $Bar

var p_value := 0.0

var max_value := 8

func _process(delta: float) -> void:
	bar.value = p_value
	if p_value >= max_value and player.is_on_floor():
		if sfx.playing == false:
			sfx.play()
	else:
		sfx.stop()
