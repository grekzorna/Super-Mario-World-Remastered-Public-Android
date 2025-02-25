class_name SliderOptionNode
extends OptionNode

@onready var label: Label = $MarginContainer/Container/Title
@onready var left_arrow: TextureRect = $MarginContainer/Container/HBoxContainer/LeftArrow
@onready var right_arrow: TextureRect = $MarginContainer/Container/HBoxContainer/LeftArrow2

var value := 1.0

var val_jump := 0.05

@export var option_title := ""

func _ready() -> void:
	pass

func update(delta: float) -> void:
	if highlighted:
		if Input.is_action_just_pressed("ui_left"):
			value -= val_jump
			SoundManager.play_ui_sound(SoundManager.menu)
		if Input.is_action_just_pressed("ui_right"):
			value += val_jump
			SoundManager.play_ui_sound(SoundManager.menu)
	$MarginContainer/Arrow.visible = highlighted
	$MarginContainer/Container/HBoxContainer/HSlider.value = value * 100
	label.text = "  " + option_title + ": " + (str(round(value * 100)) if value >= 0.01 else "0") + "%"
	value = clamp(value, 0, 1)
	highest_value = value == 1
	lowest_value = value <= 0.01
	right_arrow.modulate.a = 1 if not highest_value and highlighted else 0
	left_arrow.modulate.a = 1 if not lowest_value and highlighted else 0
