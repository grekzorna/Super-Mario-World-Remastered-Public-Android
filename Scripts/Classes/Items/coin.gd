@icon("res://Assets/Sprites/Editor/Icons/Coin.png")
class_name Coin
extends Node2D

@export var p_switch := false
var empty_block = false

var player: Player = null
var secret := false

func _ready() -> void:
	if GameManager.current_level.p_switch_active and not p_switch:
		GameManager.current_level.spawn_empty_block(global_position, true)
		queue_free()
	if secret:
		$Sprite.play("PSwitch")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		add_coin()
	elif area.get_parent() is HeldObject:
		if is_instance_valid(area.get_parent().player):
			add_coin()

func add_coin() -> void:
	GameManager.add_coin(1, global_position)
	if player != null:
		player.play_sfx("coin")
	else:
		SoundManager.play_sfx(SoundManager.coin, self)
	ParticleManager.summon_particle(ParticleManager.SPARKLE, global_position)
	queue_free()
