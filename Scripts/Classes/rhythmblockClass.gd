extends StaticBody2D

var is_active := false
@export_enum("Red", "Blue") var colour := "Red"
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite

@onready var beats_left := max_beats

const max_beats := 8

func _ready() -> void:
	if colour == "Blue":
		is_active = true
	MusicPlayer.song_beat.connect(beat)

func _process(delta: float) -> void:
	collision.set_deferred("disabled", not is_active)
	sprite.frame = 1 if is_active else 0

func beat() -> void:
	beats_left -= 1
	if beats_left <= 3:
		SoundManager.play_sfx(SoundManager.text)
	if beats_left == 0:
		is_active = !is_active
		beats_left = max_beats
		SoundManager.play_sfx(SoundManager.bullet)
