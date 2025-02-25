@icon("res://Assets/Sprites/Editor/Icons/BG.png")
@tool
class_name LevelBG
extends Node2D

@export_group("Primary BG Options")
@export var main_texture: Texture = null
@export var main_sprite_frames: SpriteFrames = null
@export var sprite_layer_frames: SpriteFrames = null
@export var fg_texture: Texture = null
@export var sky_colour: Color = Color.BLUE
@export var sky_texture: Texture2D = null
@export var fg_transparency := true
@export var custom_world_environment: Environment

@export_group("Weather Options")
@export var enable_water_wave := false
@export var enable_rain := false
@export var enable_snow := false
@export var enable_thunder := false
@export var enable_leaves := false

@export_group("Scrolling Options")
@export var enable_vertical_scroll := true
@export var enable_vertical_repeat := false
@export var bg_scroll_speed := Vector2.ZERO
@export var bg_vertical_offset := -384
@export var sprite_layer_offset := 0
@export var fg_scroll_speed := Vector2.ZERO
@export var fg_vertical_offset := -192

@onready var sky_color_rect: ColorRect = $SkyLayer/SkyColor
@onready var sky_texture_rect: TextureRect = $SkyLayer/SkyTexture
@onready var main_bg_layer: Parallax2D = $MainBGLayer
@onready var main_fg_layer: Parallax2D = $MainFGLayer

@onready var main_bg_sprite: Sprite2D = $MainBGLayer/MainTexture
@onready var main_fg_sprite: Sprite2D = $MainFGLayer/MainTexture
@onready var animated_main_texture: AnimatedSprite2D = $MainBGLayer/AnimatedMainTexture
@onready var animated_sprite_layer: AnimatedSprite2D = $MainBGLayer/AnimatedSpriteLayer

@onready var rain_layer: Parallax2D = $RainLayer
@onready var rain_sfx: AudioStreamPlayer = $RainSFX
@onready var thunder_animation: AnimationPlayer = $RainLayer/ThunderFlash/AnimationPlayer
@onready var thunder_animation_2: AnimationPlayer = $SkyLayer/ThunderFlash/AnimationPlayer

const RAIN_SPLASH = preload("res://Instances/Particles/Misc/rain_splash.tscn")
@onready var rain_cast: RayCast2D = $RainCast

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		if enable_rain:
			rain_sfx.play()
		if enable_thunder:
			thunder_timer.start()
		spawn()

func spawn() -> void:
	pass

func _process(delta: float) -> void:
	main_bg_sprite.material.set_shader_parameter("enabled", enable_water_wave)
	rain_layer.visible = enable_rain
	main_bg_sprite.visible = main_texture != null and main_sprite_frames == null
	main_fg_sprite.texture = fg_texture
	$LeafLayer.visible = enable_leaves
	if custom_world_environment != null:
		$WorldEnvironment.environment = custom_world_environment
	else:
		$WorldEnvironment.environment = null
	if main_sprite_frames != null:
		animated_main_texture.sprite_frames = main_sprite_frames
		animated_main_texture.play(main_sprite_frames.get_animation_names()[0])
	main_bg_layer.autoscroll = bg_scroll_speed
	main_fg_layer.autoscroll = fg_scroll_speed
	main_bg_layer.scroll_offset.y = bg_vertical_offset
	main_fg_layer.scroll_offset.y = fg_vertical_offset
	main_bg_layer.repeat_size.y = 432 if enable_vertical_repeat else 0
	main_bg_layer.scroll_scale.y = 1 if enable_vertical_scroll else 0
	if is_instance_valid(sprite_layer_frames):
		animated_sprite_layer.sprite_frames = sprite_layer_frames
		animated_sprite_layer.play(sprite_layer_frames.get_animation_names()[0])
	animated_sprite_layer.offset.y = sprite_layer_offset
	main_fg_layer.modulate.a = 0.3 if fg_transparency else 1
	$FGLayer.modulate.a = main_bg_layer.modulate.a
	$SnowLayer.visible = enable_snow
	if main_texture != null:
		main_bg_sprite.texture = main_texture
	sky_texture_rect.visible = sky_texture != null
	if sky_texture != null:
		sky_texture_rect.texture = sky_texture
	if enable_rain == false:
		if rain_sfx.playing:
			rain_sfx.stop()
	sky_color_rect.color = sky_colour
	update(delta)

func update(delta: float) -> void:
	pass

func cast_rain() -> void:
	var cam_center = get_viewport().get_camera_2d().get_screen_center_position()
	var cast_position = Vector2(cam_center.x, cam_center.y - 135)
	cast_position.x += randi_range(-240, 240)
	rain_cast.global_position = cast_position
	await get_tree().physics_frame
	if rain_cast.is_colliding():
		summon_rain_drop(rain_cast.get_collision_point())

func summon_rain_drop(splash_position := Vector2.ZERO) -> void:
	var node = RAIN_SPLASH.instantiate()
	node.global_position = splash_position
	add_sibling(node)
@onready var thunder_timer: Timer = $ThunderTimer

func thunder_flash() -> void:
	if enable_thunder == false:
		return
	thunder_animation_2.play("thunder")
	thunder_animation.play("thunder")
	thunder_timer.start(randi_range(5, 8))

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		for i in get_children():
			if i is Parallax2D:
				i.screen_offset = -get_viewport().global_canvas_transform.origin / get_viewport().global_canvas_transform.get_scale()
	elif enable_rain and get_tree().paused == false:
		cast_rain()
