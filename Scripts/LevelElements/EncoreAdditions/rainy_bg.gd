extends Node

@export var thunder := false
@export var low_music := true
@export var main_texture: Texture = null
@export var show_clouds := true
@onready var clouds: Parallax2D = $RainyBG/Clouds
@onready var texture: Sprite2D = $RainyBG/ParallaxLayer/MainTexture
@onready var canvas_modulate: CanvasModulate = $RainyBG/CanvasModulate
@onready var rain_sfx: AudioStreamPlayer = $RainyBG/RainSFX

const RAIN_SPLASH = preload("res://Instances/Particles/Misc/rain_splash.tscn")
@onready var og_bg := get_parent().get_node("StaticBG")

var can_splash := true

var cast: RayCast2D = null

func _ready() -> void:
	if thunder:
		$ThunderTimer.start(randi_range(5, 7))
	clouds.visible = show_clouds
	if GameManager.encore_mode == false:
		queue_free()
		return
	if low_music:
		MusicPlayer.game.pitch_scale = 0.9
	texture.texture = main_texture
	await get_tree().process_frame
	rain_sfx.play()
	if is_instance_valid(og_bg):
		og_bg.queue_free()
	get_parent().add_child(canvas_modulate.duplicate())
	canvas_modulate.queue_free()
	await get_tree().create_timer(0.5, false).timeout
	add_cast()

func _physics_process(delta: float) -> void:
	if can_splash and cast != null and GameManager.in_interior == false:
		rain_cast()

func add_cast() -> void:
	cast = RayCast2D.new()
	cast.target_position = Vector2(0, 99999)
	GameManager.current_level.add_child(cast)

func rain_cast() -> void:
	can_splash = false
	var cam_pos = get_viewport().get_camera_2d().global_position
	var pos_x = cam_pos.x + randi_range(-240, 240)
	cast.global_position = Vector2(pos_x, cam_pos.y - 135)
	if cast.is_colliding():
		summon_splash(cast.get_collision_point())
	can_splash = true

func summon_splash(splash_pos := Vector2.ZERO) -> void:
	var node = RAIN_SPLASH.instantiate()
	node.global_position = splash_pos
	GameManager.current_level.add_child(node)

func _exit_tree() -> void:
	GameManager.darkness = false
	MusicPlayer.game.pitch_scale = 1

func time_out() -> void:
	$ThunderTimer.start(randi_range(5, 8))
