class_name SettingsFile
extends Resource

## Video / Graphics Settings

@export_category("Video / Graphics")
@export var resolution := Vector2(1440, 810)
@export_enum("Windowed", "Borderless", "Fullscreen") var window_type := 0
@export var vsync_enabled := false
@export var pixel_perfect := false
@export var drop_shadows := false
@export_enum("Classic", "Compact") var hud_dragon_coin_style := 0

## Audio Settings
@export_category("Audio")
@export var master_volume := 0.5
@export var music_volume := 0.5
@export var sfx_volume := 1.0
@export var ui_volume := 1.0

## Gameplay Settings

@export_category("Gameplay")
@export var ground_pound := false
@export var air_twirl := false
@export var wall_jump := false
@export var dive := false
@export var air_flutter := false
@export var timer_enabled := false
@export var character_specific_physics := true
@export_enum("Per Save", "Per Level") var timer_type := 0
@export var yoshi_spawn_pause := false
@export_enum("Overhaul", "Classic") var autumn_type := 0
