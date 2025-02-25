extends Node2D

@onready var mushroom_1: StaticBody2D = $Mushroom1
@onready var mushroom_2: StaticBody2D = $Mushroom2

@onready var player_detect_1: Area2D = $Mushroom1/PlayerDetect
@onready var player_detect_2: Area2D = $Mushroom2/PlayerDetect

@onready var line_1: NinePatchRect = $Mushroom1/Line
@onready var line_2: NinePatchRect = $Mushroom2/Line

var tilt := 0.0
var tilt_strength := 32

var max_tilt := 64

func _ready() -> void:
	const AUTUMN_LINE = preload("res://Assets/Sprites/Tilesets/Decorations/MushroomAutumnTiles.png")
	if GameManager.autumn and SettingsManager.settings_file.autumn_type == 0:
		line_1.texture = AUTUMN_LINE
		line_2.texture = AUTUMN_LINE

func _physics_process(delta: float) -> void:
	var player_amount_1 := 0
	var player_amount_2 := 0
	var player_total := 0
	for i in player_detect_1.get_overlapping_areas():
		if i.get_parent() is Player:
			player_amount_1 += 1
	for i in player_detect_2.get_overlapping_areas():
		if i.get_parent() is Player:
			player_amount_2 += 1
	player_total = player_amount_1 + -player_amount_2
	if player_total == 0:
		tilt = lerpf(tilt, 0, delta)
	else:
		tilt += (tilt_strength * player_total) * delta
	
	mushroom_1.position.y = tilt
	mushroom_2.position.y = -tilt
