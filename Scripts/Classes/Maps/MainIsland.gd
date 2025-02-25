extends MapLevel


func _on_sgs_level_cleared() -> void:
	if $BowserValleyEntrance/SGS/Path/Sprite2D10.visible:
		return
	MusicPlayer.map.stop()
	await get_tree().create_timer(0.5, false).timeout
	$BowserValleyEntrance/SGS/Music.play()
