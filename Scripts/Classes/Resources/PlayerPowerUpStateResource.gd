@icon("res://Assets/Sprites/Editor/Icons/PowerState.png")
class_name PlayerPowerUpState
extends Resource

@export var state_name := ""
@export var sprite_frame_name := "" ## Name used for the sprite frame lookup. Usually will be the same as the state name.
@export var power_script: Script = null
@export var states: Array[Script] = []
@export_enum("Small", "Regular") var hitbox_size: String = "Regular"
@export var transform_animation := false
@export var power_down: PlayerPowerUpState = null
@export var power_sfx_override: AudioStream = null
@export var power_tier := 0
@export var item_sprite: Texture = null
@export var can_water_damage := false
@export var technical_swim := false
@export var sprite_extras: Array[PackedScene]
