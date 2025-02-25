extends Enemy

@export var play_sfx := false
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	if play_sfx:
		sfx.play()
