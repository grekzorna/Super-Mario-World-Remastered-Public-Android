@icon("res://Assets/Sprites/Editor/Icons/DragonCoin.png")
class_name DragonCoin
extends Node2D

var player: Player = null

signal collected
signal all_collected

@export var behind_fence := false ## Used for when the coin needs to be behind a climbable fence, requiring the player to be on the same side to collect it.

var id := -1

var already_got := false

var path_to_self := ""

var scores := [1000, 2000, 4000, 8000, 0]

func _ready() -> void:
	path_to_self = (str(get_tree().root.get_path_to(self)))
	await get_tree().physics_frame
	if behind_fence:
		z_index = -2#
	if SaveManager.current_save == {}:
		SaveManager.current_save = SaveManager.save_file_template
	check_drag_coins()
	if SaveManager.current_save.dragon_levels.has(GameManager.current_level_info.resource_path):
		already_got = true
	else:
		already_got = SaveManager.current_save.dragon_coins_collected[GameManager.current_level_info.resource_path].has(path_to_self)
	if already_got:
		set_visibility_layer_bit(1, true)
		set_visibility_layer_bit(0, false)
		$Sprite.play("collected")

static func check_drag_coins() -> void:
	if GameManager.current_level_info == null:
		GameManager.current_level_info = LevelInfo.new()
	if SaveManager.current_save.dragon_coins_collected.has(GameManager.current_level_info.resource_path) == false:
		SaveManager.current_save.dragon_coins_collected[GameManager.current_level_info.resource_path] = []
	if SaveManager.current_save.dragon_levels.has(GameManager.current_level_info.resource_path):
		GameManager.dragon_coins = 0
	else:
		if SaveManager.current_save.dragon_coins_collected.has(GameManager.current_level_info.resource_path):
			GameManager.dragon_coins = SaveManager.current_save.dragon_coins_collected[GameManager.current_level_info.resource_path].size()

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
	SaveManager.current_save.dragon_coins_collected[GameManager.current_level_info.resource_path].append(path_to_self)
	SoundManager.play_sfx(SoundManager.coin_special, self)
	ParticleManager.summon_particle(ParticleManager.SPARKLE, global_position)
	GameManager.add_coin(1, global_position)
	if GameManager.all_coins_collected:
		GameManager.add_life(1, global_position)
	else:
		GameManager.dragon_coins += 1
	var score_index = GameManager.dragon_coins
	score_index = clamp(score_index - 1, 0, 4)
	GameManager.add_score(scores[score_index], true, global_position)
	var max_amount := 5
	if GameManager.current_level_info != null:
		max_amount = GameManager.current_level_info.dragon_coin_amount
	if GameManager.dragon_coins >= max_amount:
		all_coins_collected()
	

func grabbed_already() -> void:
	ParticleManager.summon_particle(ParticleManager.SPARKLE, global_position)
	SoundManager.play_sfx(SoundManager.coin, self, 1.5)
	GameManager.add_score(1000, true, global_position)
	if check_if_all_in_area():
		AchievementManager.unlock_achievement(GameManager.current_map_area.dragon_coin_achievement)


func all_coins_collected() -> void:
	all_collected.emit()
	GameManager.all_coins_collected = true
	SoundManager.play_sfx(SoundManager.one_up, self)
	GameManager.add_life(1, global_position)
	GameManager.dragon_coins = 0
	SaveManager.current_save.dragon_levels.append(GameManager.current_level_info.resource_path)
	AchievementManager.unlock_achievement(preload("res://Resources/Achievements/General/DragCoin.tres"))
	if check_if_all_in_area():
		AchievementManager.unlock_achievement(GameManager.current_map_area.dragon_coin_achievement)

func check_if_all_in_area() -> bool:
	var index := 0
	var amount := 0
	var total_levels := 0
	if GameManager.current_map_area == null:
		return false
	for i in GameManager.current_map_area.levels:
		if i != null:
			if i.has_dragon_coins:
				total_levels += 1
	for i in GameManager.current_map_area.levels:
		if SaveManager.current_save.dragon_levels.has(i.resource_path):
			amount += 1
	print([amount, total_levels])
	return amount >= total_levels
