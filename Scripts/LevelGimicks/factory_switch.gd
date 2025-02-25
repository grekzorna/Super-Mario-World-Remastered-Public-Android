extends StaticBody2D

signal pressed
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		var player: Player = area.get_parent()
		if player.velocity.y > 0:
			activate()

func activate() -> void:
	SoundManager.play_sfx(SoundManager.bullet, self)
	SoundManager.play_sfx(SoundManager.switch_activate, self)
	for i in CoopManager.alive_players.values():
		i.state_machine.transition_to("Freeze", {"Gravity" = true})
	sprite.play("Pressed")
	hitbox.queue_free()
	pressed.emit()
