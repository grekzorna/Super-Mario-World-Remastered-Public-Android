extends Level

var selected_index := 0
@export var sections: Array[SettingsSection] = []
var current_section: SettingsSection = null

func _ready() -> void:
	MusicPlayer.update_song_label("Mario Kart DS - Options Menu", "Fyre150")
	await get_tree().process_frame
	set_starting_values()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_tab_left"):
		selected_index -= 1
		SoundManager.play_ui_sound(SoundManager.select)
	elif Input.is_action_just_pressed("ui_tab_right"):
		selected_index += 1
		SoundManager.play_ui_sound(SoundManager.select)
	if Input.is_action_just_pressed("debug_clear"):
		SettingsManager.settings_file = SettingsManager.settings_template
		SoundManager.play_ui_sound(SoundManager.cape_fly)
		SettingsManager.save_settings()
		SettingsManager.apply_settings(SettingsManager.get_file())
	selected_index = wrap(selected_index, 0, sections.size())
	for i in sections:
		i.visible = (sections[selected_index]) == i
		if i.visible:
			current_section = i
		i.selected = i.visible
	$TitleHeader/SettingsHeader.text = current_section.title
	if Input.is_action_just_pressed("apply_settings"):
		apply_settings()
	if Input.is_action_just_pressed("ui_back"):
		TransitionManager.transition_to_menu("res://Instances/UI/Menus/title_screen.tscn", self)

func set_starting_values() -> void:
	for i in sections:
		i.set_option_node_values()

func apply_settings() -> void:
	for i in [$DisplaySettings, $AudioSettings, $GameplaySettings, $AbilitySettings]:
		var options = i.get_chosen_options()
		for x in options.keys():
			SettingsManager.settings_file[x] = options[x]
	SettingsManager.settings_file["sprite_settings"] = $SpriteSettings.get_chosen_options()
	SoundManager.play_ui_sound(SoundManager.coin)
	SettingsManager.apply_settings(SettingsManager.settings_file)
	SettingsManager.save_settings()
