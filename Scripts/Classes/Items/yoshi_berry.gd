class_name YoshiBerry
extends Node2D

@export_enum ("Red", "Green", "Pink") var colour := 0
@onready var sprite: AnimatedSprite2D = $Sprite

@export var colour_hexes: Array[Color] = []

func _ready() -> void:
	sprite.play(str(colour))
	if SettingsManager.sprite_settings.yoshi_berry == 1:
		sprite.material.set_shader_parameter("colour_1", colour_hexes[colour])
	else:
		sprite.material.set_shader_parameter("colour_1", Color(0, 0, 0, 0))



func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().riding_yoshi:
			if area.get_parent().yoshi_stored != null:
				return
			area.get_parent().yoshi_item = self
			area.get_parent().yoshi_berry_eat(colour)
