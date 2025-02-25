extends Node2D

@export var coin: CrystalCoin = null
@export var teleport := false
@export var teleport_location := Vector2.ZERO
@onready var sprite: AnimatedSprite2D = $Sprite

@onready var collected_sprite: AnimatedSprite2D = $CollectedSprite
@onready var particles: GPUParticles2D = $Particles

var collected := false

func _ready() -> void:
	collected = coin.collected
	if collected:
		collected_sprite.show()
		particles.hide()
	else:
		collected_sprite.hide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if not collected:
			area.get_parent().crystal_coin_collect(self)
			coin.collected = true
			GameManager.player.hud.crystal_coin_title = coin.title
			GameManager.current_level.coins_collected += 1
			hide()
			await get_tree().create_timer(3).timeout
			ResourceSaver.save(coin)
			GameManager.player.hud.refresh_coin_list()
			queue_free()
		else:
			SoundManager.play_sfx(SoundManager.coin_special)
			queue_free()
