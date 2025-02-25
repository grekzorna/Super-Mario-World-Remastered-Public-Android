extends ColorRect

var can_change := false

@export var debug_fast_enter := true

func _ready() -> void:
	if OS.is_debug_build() and debug_fast_enter:
		debug_enter()
		return
	await get_tree().create_timer(2, false).timeout
	can_change = true
	await get_tree().create_timer(8, false).timeout
	go_to_menu()

func go_to_menu() -> void:
	if can_change:
		can_change = false
		TransitionManager.transition_to_menu(TransitionManager.TITLE_SCREEN, self)

func debug_enter() -> void:
	SaveManager.load_file(0)
	SaveManager.selected_file = 0
	var save = SaveManager.current_save
	GameManager.map_point_save = save.map_point_name
	SaveManager.apply_data()
	GameManager.map_point_save = save.map_point_name
	TransitionManager.transition_to_map(save.current_map, self, false, GameManager.map_point_save)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dive_0"):
		debug_enter()
	if Input.is_action_just_pressed("ui_accept"):
		go_to_menu()

func play_rise() -> void:
	SoundManager.play_ui_sound(SoundManager.balloon)

func play_alert() -> void:
	SoundManager.play_ui_sound(SoundManager.correct)
