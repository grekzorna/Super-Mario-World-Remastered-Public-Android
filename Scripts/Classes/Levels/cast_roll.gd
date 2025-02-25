extends Node
@onready var canvas_group: CanvasGroup = $CanvasGroup

var things := []

var active := false

@export var debug_test := false

var bgs := [
	preload("res://Assets/Sprites/Backgrounds/Overworld/Bushes/Bush4.png"),
	preload("res://Assets/Sprites/Backgrounds/Overworld/Clouds/Clouds1.png"),
	preload("res://Assets/Sprites/Backgrounds/Overworld/Rocks/Rock5.png"),
	preload("res://Assets/Sprites/Backgrounds/Overworld/Mountains/CylMountains.png"),
	preload("res://Assets/Sprites/Backgrounds/Overworld/Mountains/Mountains1.png"),
	preload("res://Assets/Sprites/Backgrounds/Underground/BG1.png"),
	preload("res://Assets/Sprites/Backgrounds/Underwater/BG1.png"),
	preload("res://Assets/Sprites/Backgrounds/GhostHouse/BG4.png"),
	preload("res://Assets/Sprites/Backgrounds/Castle/Fortress2.png"),
	preload("res://Assets/Sprites/Backgrounds/Castle/Halls2.png"),
	preload("res://Assets/Sprites/Backgrounds/Castle/Fortress2.png"),
	preload("res://Assets/Sprites/Backgrounds/Castle/Halls3.png")
	]

const autunn_bgs := [
	preload("res://Assets/Sprites/Backgrounds/Overworld/Bushes/BushAutumn.png"),
	preload("res://Assets/Sprites/Backgrounds/Overworld/Clouds/AutumnClouds.png"),
	preload("res://Assets/Sprites/Backgrounds/Overworld/Rocks/RocksAutumn.png"),
	preload("res://Assets/Sprites/Backgrounds/Overworld/Mountains/CylMountainsAutumn2.png"),
	preload("res://Assets/Sprites/Backgrounds/Overworld/Mountains/MountainsAutumn2.png"),
	preload("res://Assets/Sprites/Backgrounds/Underground/BGAutumn.png"),
	preload("res://Assets/Sprites/Backgrounds/Underwater/BG1.png"),
	preload("res://Assets/Sprites/Backgrounds/GhostHouse/BG4.png"),
	preload("res://Assets/Sprites/Backgrounds/Castle/Fortress2.png"),
	preload("res://Assets/Sprites/Backgrounds/Castle/Halls2.png"),
	preload("res://Assets/Sprites/Backgrounds/Castle/Fortress2.png"),
	preload("res://Assets/Sprites/Backgrounds/Castle/Halls3.png")
]

var colours := [
	Color("f8e0b0"),
	Color("d8f8d8"),
	Color("0060b8"),
	Color("98e0e0"),
	Color("d8f8d8"),
	Color("000000"),
	Color("0060b8"),
	Color("0060b8"),
	Color("104838"),
	Color("183048"),
	Color("d8f8d8"),
	Color("000000")
	]

const autumn_colours := [
	Color("f8e0b0"),
	Color("d8f8d8"),
	Color("0060b8"),
	Color("98e0e0"),
	Color("d8f8d8"),
	Color("000000"),
	Color("0060b8"),
	Color("0060b8"),
	Color("104838"),
	Color("183048"),
	Color("d8f8d8"),
	Color("000000")
	]

func _ready() -> void:
	$LevelBG.hide()
	$CanvasGroup/Guide.hide()
	for i in canvas_group.get_children():
		if i is Node2D:
			if i.get_node_or_null("Top") != null:
				things.append(i)
				i.hide()
	if debug_test == false:
		$Camera2D.queue_free()
		await $"../Cutscene".finished
	else:
		active = true
		$Music.play()
		$Animation.play("Enter")
		await get_tree().create_timer(4, false).timeout
	await get_tree().create_timer(1, false).timeout
	$LevelBG.show()
	activate()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("jump_0") and active:
		Engine.time_scale = 8
	else:
		Engine.time_scale = 1

func activate() -> void:
	$LevelBG.show()
	active = true
	var index := 0
	for i in things:
		if GameManager.autumn and SettingsManager.settings_file.autumn_type == 0:
			$LevelBG.main_texture = autunn_bgs[index]
			$LevelBG.sky_colour = autumn_colours[index]
		else:
			$LevelBG.main_texture = bgs[index]
			$LevelBG.sky_colour = colours[index]
		i.show()
		tween_left(i.get_node("Top"))
		tween_right(i.get_node("Bottom"))
		await get_tree().create_timer(7, false).timeout
		left_exit(i.get_node("Top"))
		right_exit(i.get_node("Bottom"))
		await get_tree().create_timer(3, false).timeout
		i.hide()
		index += 1
	$Final/Animation.play("Appear")
	await get_tree().create_timer(5.5, false).timeout
	$TheEnd/Animation.play("Appear")
	active = false
	await get_tree().create_timer(4, false).timeout
	tween_volume()

func tween_left(node) -> void:
	node.global_position.x = 480
	var tween = create_tween()
	tween.tween_property(node, "global_position:x", 0, 3)

func tween_volume() -> void:
	var tween = create_tween()
	tween.tween_property($Music, "volume_db", -40, 5)
	await tween.finished
	$Music.stop()

func tween_right(node) -> void:
	node.global_position.x = -480
	var tween = create_tween()
	tween.tween_property(node, "global_position:x", 0, 3)

func right_exit(node) -> void:
	node.global_position.x = 0
	var tween = create_tween()
	tween.tween_property(node, "global_position:x", 480, 3)

func left_exit(node) -> void:
	node.global_position.x = 0
	var tween = create_tween()
	tween.tween_property(node, "global_position:x", -480, 3)
