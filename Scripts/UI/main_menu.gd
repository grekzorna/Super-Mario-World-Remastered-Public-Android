extends Control
@onready var logo_animations: AnimationPlayer = $Logo/AnimationPlayer
@onready var bg: TextureRect = $BG
@onready var label_flash: AnimationPlayer = $Label/AnimationPlayer
@onready var music: AudioStreamPlayer = $Music
@onready var enter: AudioStreamPlayer = $Enter
@onready var slide: AnimationPlayer = $TextureRect/AnimationPlayer
@onready var logo: Sprite2D = $Logo
@onready var menu_scene = preload("res://Instances/UI/Menus/main_menu.tscn")
var can_start := false

func _ready() -> void:
	slide.play_backwards("Close")
	await slide.animation_finished
	logo.show()
	logo_animations.play("Appear")
	await logo_animations.animation_finished
	logo_animations.play("float")
	can_start = true
	label_flash.play("loop")

func _process(delta: float) -> void:
	const bg_move_speed := 50
	bg.position.x -= bg_move_speed * delta
	bg.position.x = wrap(bg.position.x, 0, -512)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") and can_start:
		can_start = false
		label_flash.speed_scale = 5
		music.stop()
		SoundManager.play_sfx(preload("res://Assets/Audio/SFX/correct.wav"))
		await get_tree().create_timer(1, false).timeout
		slide.play("Close")
		enter.play()
		await slide.animation_finished
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_packed(menu_scene)
		
