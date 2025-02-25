extends Node2D

var power: PlayerPowerUpState
@onready var sprite: Sprite2D = $Sprite

const fall_speed := 60

func _ready() -> void:
	sprite.texture = power.item_sprite
	@warning_ignore("integer_division")
	sprite.hframes = sprite.texture.get_width() / 16
	@warning_ignore("integer_division")
	sprite.vframes = sprite.texture.get_height() / 16

func _physics_process(delta: float) -> void:
	global_position.y += fall_speed * delta
	if global_position.y >= 999:
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().power_up(power)
		queue_free()
