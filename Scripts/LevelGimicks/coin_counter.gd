extends Node2D

@export var coin_target := 600

var active := false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		$Hitbox.queue_free()
		activate()

func _process(delta: float) -> void:
	var amount_left = clamp(coin_target - GameManager.coin_counter_coins_collected, 0, 9999)
	$CanvasLayer/Control/Container/Text.text = str(amount_left)
	if active and GameManager.coin_counter_coins_collected >= coin_target:
		all_collected()

func activate() -> void:
	active = true
	$Sprite.hide()
	SoundManager.play_sfx(SoundManager.magic, self)
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
	GameManager.coin_counter_coins_collected = 0
	$CanvasLayer/Control.show()
	for i in [%Puff1, %Puff2, %Puff3]:
		i.play("default")

func all_collected() -> void:
	active = false
	SoundManager.play_global_sfx(SoundManager.checkpoint)
	await get_tree().create_timer(1, false).timeout
	GameManager.add_life(3, CoopManager.get_first_active_player().global_position)
	$CanvasLayer/Control/Container.hide()
	for i in [%Puff1, %Puff2, %Puff3]:
		i.play("default")
	await get_tree().create_timer(1, false).timeout
	queue_free()
