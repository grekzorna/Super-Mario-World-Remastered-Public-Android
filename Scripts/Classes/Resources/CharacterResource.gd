@icon("res://Assets/Sprites/Editor/Icons/Character.png")
class_name CharacterResource
extends Resource

@export var character_name := ""
@export var base_character_scene: PackedScene = null
@export var character_script: Script = null
@export var char_colour := Color.WHITE

@export var custom_properties := {}
@export var sound_library: SoundLibrary = preload("res://Resources/SoundLibraries/Default.tres")

@export var character_id := -1
@export var character_skin: CharacterResource = null ## Use if this character is meant to simply be a "skin" of another exsiting character, skins can be selected by using the controller bumpers or Q & E.

@export var power_sprite_extra_offsets := {}
@export var power_sprite_extra_replaces := {}

@export var power_state_script_replace := {}

@export var override_power_state: PlayerPowerUpState = null

@export var HUDTitle: Texture = null
@export var HUDLetter: Texture = null
@export var ending_portrait: Texture = null
@export var ending_firework_mask: Texture = null
@export var map_sprites: SpriteFrames = null

@export var selection_idle: Texture = null
@export var selection_selected: Texture = null
@export var selection_sfx: AudioStream = preload("res://Assets/Audio/SFX/coin.wav")

func _init() -> void:
	pass
