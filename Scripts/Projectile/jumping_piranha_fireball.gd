extends Node2D

var velocity := Vector2.ZERO

var direction := 1

func _ready() -> void:
	velocity.y = -200
	velocity.x = 100 * direction

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	if SettingsManager.sprite_settings.fireball == 1:
		$Sprite.global_rotation_degrees += 360 * delta
	velocity.x = lerpf(velocity.x, 0, delta)
	velocity.y += 10
	velocity.y = clamp(velocity.y, -888, 150)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.damage()
