@icon("res://Assets/Sprites/Editor/Icons/Yoshi.png")
extends Node2D


signal tongue_hit(area: Area2D)
signal tongue_action_finished

@onready var head: Sprite2D = $Body/Head
@onready var body: Sprite2D = $Body
@export var colour := 1
@onready var yoshi_animations: AnimationPlayer = $YoshiAnimations
@onready var wings: AnimatedSprite2D = $Body/Wings
@onready var tongue_line: Line2D = $Body/Head/TongueLine
@onready var tongue: Sprite2D = $Body/Head/Tongue

var custom_modulate_a := 1.0

@export var shader_colour_1 := Color.BLACK
@export var shader_colour_2 := Color.BLACK
@export var shader_colour_3 := Color.BLACK

func _process(delta: float) -> void:
	set_shader_colours()
	tongue_line.set_point_position(1, tongue_line.to_local(tongue.global_position))
	tongue_line.set_point_position(0, Vector2(tongue_line.get_point_position(0).x, tongue_line.to_local(tongue.global_position).y))
	tongue_line.visible = tongue.visible

func set_shader_colours() -> void:
	body.material.set_shader_parameter("alpha", custom_modulate_a)
	for i in 3:
		body.material.set_shader_parameter("colour_" + str(i + 1), (Yoshi.colour_values[colour][i] / 255))
	if SettingsManager.sprite_settings.yoshi == 0:
		body.material.set_shader_parameter("arm_colour", Yoshi.yoshi_arm_orange)
	else:
		body.material.set_shader_parameter("arm_colour", Yoshi.colour_values[colour][0] / 255)

func _on_tongue_box_area_entered(area: Area2D) -> void:
	tongue_hit.emit(area)

func tongue_finish() -> void:
	tongue_action_finished.emit()
