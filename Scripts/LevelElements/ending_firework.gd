extends Node2D

var positions := []

@onready var particle: AnimatedSprite2D = $Particle

var colour := Color.WHITE
var mask_texture: Texture = null

const FIREWORKBANG = preload("res://Instances/Particles/Misc/fireworkbang.tscn")
func _ready() -> void:
	setup_positions()
	SoundManager.play_global_sfx("res://Assets/Audio/SFX/fireworks.wav")
	modulate = colour
	for i in positions:
		var new = FIREWORKBANG.instantiate()
		print(i)
		add_child(new)
		new.position = i * 8

func setup_positions() -> void:
	var mask_image = mask_texture.get_image()
	for y in mask_image.get_height():
		for x in mask_image.get_width():
			if mask_image.get_pixel(x, y) == Color.BLACK:
				positions.append(Vector2(x, y))
