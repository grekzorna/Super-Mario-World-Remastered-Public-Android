extends Node
@onready var LUIGI = load("res://Resources/Characters/Luigi.tres")
var sprite_style := "SMAS"

var sprites := ["", "SMA2", "SMAS"]

var selection_sprites := {"": [preload("res://Assets/Sprites/Characters/Luigi/SelectionSprites/SMMIdle.tres"), preload("res://Assets/Sprites/Characters/Luigi/SelectionSprites/SMMActive.tres")],
				"SMAS": [preload("res://Assets/Sprites/Characters/Luigi/SelectionSprites/SMASIdle.tres"), preload("res://Assets/Sprites/Characters/Luigi/SelectionSprites/SMASActive.tres")],
				"SMA2": [preload("res://Assets/Sprites/Characters/Luigi/SelectionSprites/SMA2Idle.tres"), preload("res://Assets/Sprites/Characters/Luigi/SelectionSprites/SMA2Active.tres")]}

func _ready() -> void:
	sprite_style = sprites[SettingsManager.sprite_settings["luigi"]]
	LUIGI.character_name = "Luigi" + sprite_style
	LUIGI.selection_idle = selection_sprites[sprite_style][0]
	LUIGI.selection_selected = selection_sprites[sprite_style][1]
