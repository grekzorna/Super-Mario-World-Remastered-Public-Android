extends Control

@onready var buttons = [$Buttons/Container/Play, $Buttons/Container/Settings, $Buttons/Container/Quit]

var button_desc = ["start the game", "adjust game settings", "quit the game"]

var button_colors = [Color("9cdb43"), Color("b8aeff"), Color("b4202a")]
@onready var buttons_container: CenterContainer = $Buttons

@onready var arrow: TextureRect = $Arrow
@onready var description: Label = $Description
@onready var settings_menu: Control = $SettingsMenu
@onready var music: AudioStreamPlayer = $Music

var selected_button: TextureRect = null
var selected_index := 0

var sway := 0.0

var active := true

signal settings
signal play
signal exit

func _ready() -> void:
	settings.connect(settings_menu.open)

func _process(delta: float) -> void:
	handle_buttons(delta)
	description.text = button_desc[selected_index]
	description.add_theme_color_override("font_color",(button_colors[selected_index]))
	arrow.global_position.x = lerpf(arrow.global_position.x, (selected_button.global_position.x + (selected_button.size.x / 2 ) - 20), delta * 20)
	
	if active:
		if Input.is_action_just_pressed("ui_right"):
			selected_index += 1
			animate_text_update()
			#SoundManager.play_sfx(SoundManager.menu)
		elif Input.is_action_just_pressed("ui_left"):
			selected_index -= 1
			animate_text_update()
			#SoundManager.play_sfx(SoundManager.menu)
		selected_index = clamp(selected_index, 0, 2)
		
		if Input.is_action_just_pressed("ui_accept"):
			button_select()

func button_select() -> void:
	match selected_index:
		0:
			game_start()
			emit_signal("play")
		1:
			emit_signal("settings")
			settings_open()
		2:
			emit_signal("exit")

func settings_open() -> void:
	active = false
	music.stop()
	await settings_menu.closed
	active = true
	music.play()

func game_start() -> void:
	return
	#TransitionManager.transition_to_level(preload("res://Instances/Levels/IntroCutscene.tscn"), self)

func handle_buttons(delta) -> void:
	sway += 1 * delta
	selected_button = buttons[selected_index]
	for i in buttons:
		i.material.set_shader_parameter("width", 0)
		if selected_button == i:
			i.material.set_shader_parameter("width", 2)
			i.position.y = lerpf(i.position.y, -8, delta * 20)
		else:
			i.position.y = lerpf(i.position.y, 0, delta * 20)

func animate_text_update() -> void:
	description.pivot_offset = description.size / 2
	description.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(description, "scale", Vector2.ONE, 0.1)
