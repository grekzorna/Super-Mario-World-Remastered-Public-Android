extends Node2D

var move := 0.0
const move_speed := 2
@onready var sprite: Node2D = $Sprite

signal grabbed

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	move += move_speed * delta
	global_position.y -= 8 * delta
	global_position.x += 32 * delta
	sprite.position.y = (sin(move) * 8) - 8

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		if area.owner.riding_yoshi:
			area.owner.yoshi_grab_wings()
			queue_free()
