extends Control

var time := 0.0

var stopped := false



func _process(delta: float) -> void:
	if not stopped:
		if SettingsManager.settings_file.timer_enabled:
			if SettingsManager.settings_file.timer_type == 0:
				visible = SettingsManager.settings_file.timer_enabled and (SaveManager.current_save) != {} and not GameManager.playing_custom_level
				time = GameManager.time_played
			elif SettingsManager.settings_file.timer_type == 1:
				visible = is_instance_valid(GameManager.current_level) and is_instance_valid(CoopManager.get_first_any_player())
				time = GameManager.level_time
		else:
			hide()
	$Label.text = format_time(time)

func format_time(time := 0.0) -> String:
	var mils = str(int(fmod(time, 1) * 1000))
	var secs = str(int((fmod(time, 60))))
	var mins = str(int((fmod(time, 60 * 60) / 60)))
	var hrs = str(int((time / (60 * 60))))
	if int(mils) < 100:
		mils = mils + "0"
	if int(secs) < 10:
		secs = "0" + secs
	
	if int(mins) < 10:
		mins = "0" + mins
	
	if int(hrs) < 10:
		hrs = "0" + hrs
	
	var time_passed = hrs + ":" + mins + ":" + secs + ":" + mils
	return time_passed

func stop() -> void:
	if SettingsManager.settings_file.timer_enabled:
		SoundManager.play_ui_sound(SoundManager.switch_activate)
	stopped = true
	$Animation.play("Flash")

func resume() -> void:
	stopped = false
