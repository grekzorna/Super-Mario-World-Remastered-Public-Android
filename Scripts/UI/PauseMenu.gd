extends Control

@onready var options = [$Box/MarginContainer/Vbox/Label, $Box/MarginContainer/Vbox/Label2, $Box/MarginContainer/Vbox/Label3]
@onready var arrow: TextureRect = $Arrow

var selected_index := 0

var can_select := true

var valid_choices := [true, true, true]

var can_quit := false
var can_restart := false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	visible = GameManager.game_paused
	if is_instance_valid(GameManager.current_level) == false or is_instance_valid(CoopManager.get_first_any_player()) == false or GameManager.can_pause == false:
		return
	can_quit = players_grounded_check()
	can_restart = players_grounded_check() and more_than_one_life_check()
	valid_choices[2] = can_quit
	valid_choices[1] = can_restart
	if options[selected_index] != null:
		arrow.global_position.y = options[selected_index].global_position.y
	if GameManager.game_paused and can_select:
		if Input.is_action_just_pressed("ui_down"):
			selected_index += 1
			SoundManager.play_ui_sound(SoundManager.select)
		elif Input.is_action_just_pressed("ui_up"):
			selected_index -= 1
			SoundManager.play_ui_sound(SoundManager.select)
		if Input.is_action_just_pressed("ui_accept"):
			option_selected()
	var index := 0
	for i in options:
		i.modulate = Color.WEB_GRAY if valid_choices[index] == false else Color.WHITE
		index += 1
	selected_index = clamp(selected_index, 0, options.size() - 1)
	if Input.is_action_just_pressed("pause"):
		pause_toggle()

func pause_toggle() -> void:

	if get_tree().paused:
		if GameManager.game_paused:
			resume_game()
	elif GameManager.game_paused == false:
		pause_game()

func players_grounded_check() -> bool:
	for i in CoopManager.alive_players.values():
		if is_instance_valid(i):
			if i.is_on_floor() == false and not i.is_on_wall():
				return false
	return true

func more_than_one_life_check() -> bool:
	return GameManager.lives > 0

func option_selected() -> void:
	if can_select:
		can_select = false
	else:
		return
	if valid_choices[selected_index] == false:
		can_select = true
		SoundManager.play_ui_sound(SoundManager.wrong)
		return
	SoundManager.play_ui_sound(SoundManager.correct)
	await select_animation(options[selected_index])
	do_option()
	selected_index = 0

func resume_game() -> void:
	GameManager.game_paused = false
	get_tree().paused = false

func pause_game() -> void:
	SoundManager.play_ui_sound("res://Assets/Audio/SFX/pause.wav")
	GameManager.game_paused = true
	get_tree().paused = true
	can_select = true

func do_option() -> void:
	match selected_index:
		0:
			resume_game()
		1:
			MusicPlayer.stop_level_music()
			for i in 4:
				CoopManager.player_power_states[i] = CoopManager.SMALL
				CoopManager.player_yoshis[i] = false
			GameManager.reset_values()
			TransitionManager.transition_to_level((GameManager.starting_level_path), GameManager.current_level, false)
			GameManager.game_paused = false
		2:
			MusicPlayer.stop_level_music()
			GameManager.reset_values()
			if GameManager.playing_custom_level:
				TransitionManager.transition_to_menu(GameManager.CUSTOM_LEVEL_SELECT, GameManager.current_level)
			else:
				TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, false)
			GameManager.game_paused = false

func select_animation(option) -> void:
	for i in 5:
		option.modulate.a = 0
		await get_tree().create_timer(0.05).timeout
		option.modulate.a = 1
		await get_tree().create_timer(0.05).timeout
	return
		
