class_name PeachCoin
extends DragonCoin
const ALLRED = preload("res://Assets/Audio/SFX/Allred.wav")
func _ready() -> void:
	if SaveManager.current_save == {}:
		SaveManager.current_save = SaveManager.save_file_template
	await get_tree().physics_frame
	if SaveManager.current_save.peach_coins_unlocked == false:
		queue_free()
		return
	if behind_fence:
		z_index = -2#
	if SaveManager.current_save == {}:
		SaveManager.current_save = SaveManager.save_file_template
	
	if GameManager.current_level_info == null:
		GameManager.current_level_info = LevelInfo.new()
	already_got = check_if_collected()
	if already_got:
		set_visibility_layer_bit(1, true)
		set_visibility_layer_bit(0, false)
		$Sprite.play("collected")

static func check_if_collected() -> bool:
	GameManager.peach_coin_collected = SaveManager.current_save.peach_coins_collected.has(GameManager.current_level_info.resource_path)
	return GameManager.peach_coin_collected

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		if behind_fence:
			if player.z_index < 0:
				on_collect()
		else:
			on_collect()
	elif area.get_parent() is HeldObject:
		if is_instance_valid(area.get_parent().player):
			on_collect()

func on_collect() -> void:
	if already_got:
		grabbed_already()
	else:
		coin_collect()
	queue_free()

func coin_collect() -> void:
	collected.emit()
	SaveManager.current_save.peach_coins_collected.append(GameManager.current_level_info.resource_path)
	check_if_all_collected()
	SoundManager.play_sfx(ALLRED, self)
	GameManager.peach_coin_collected = true
	ParticleManager.summon_particle(ParticleManager.SPARKLE, global_position)
	GameManager.add_coin(1, global_position)
	GameManager.add_score(500, true, global_position)
	
const PEACH_COINS = preload("res://Resources/Achievements/Completionist/PeachCoins.tres")

func check_if_all_collected() -> void:
	var total_needed := 0
	for i in GameManager.current_campaign.map_areas:
		for x in i.levels:
			if x.has_peach_coin:
				total_needed += 1
	if SaveManager.current_save.peach_coins_collected.size() >= total_needed:
		AchievementManager.unlock_achievement(PEACH_COINS)

func grabbed_already() -> void:
	check_if_all_collected()
	ParticleManager.summon_particle(ParticleManager.SPARKLE, global_position)
	SoundManager.play_sfx(SoundManager.coin, self, 1.5)
	GameManager.add_score(1000, true, global_position)
