class_name StarRoadWarp
extends MapPoint

@export var standard_check := false

func spawn() -> void:
	if standard_check:
		if check_if_beaten(SaveManager.current_save.beaten_levels):
			$Visual.always_show = true
			$Visual.modulate.a = 1
			show()
	if check_if_beaten(SaveManager.current_save.special_beaten_levels):
		$Visual.always_show = true
		$Visual.modulate.a = 1
		show()
	activated.connect(warp_player)

func warp_player() -> void:
	GameManager.current_map.can_move = false
	GameManager.current_map.player_visual.spinning = true
	SoundManager.play_sfx(SoundManager.cape_get, self)
	tween_player()
	await get_tree().create_timer(2, false).timeout
	print(warp_point_name)
	TransitionManager.transition_to_map(map_warp, GameManager.current_map, false, warp_point_name, true)

func tween_player() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(GameManager.current_map.player_visual.get_node("Player1Sprite"), "offset:y", -256, 2.5)
