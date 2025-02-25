extends OptionNode

@export var input_action := ""

@onready var joypad_button_texture: TextureRect = $Container/ControllerButton

var current_controller_brand := ""

var controller_action_button: InputEvent = null
var keyboard_action_key: InputEvent = null

func _ready() -> void:
	if input_action != "":
		controller_action_button = InputHelper.get_joypad_inputs_for_action(input_action)[0]
		keyboard_action_key = InputHelper.get_keyboard_inputs_for_action(input_action)[0]
	joypad_button_texture.texture = get_joypad_button(controller_action_button).xbox_texture
	print([controller_action_button,
	keyboard_action_key])

func _process(delta: float) -> void:
	current_controller_brand = InputHelper.guess_device_name()

func _physics_process(delta: float) -> void:
	pass

func get_joypad_button(input_event: InputEvent) -> JoypadButton:
	for i in InputHelper.joypad_buttons:
		if input_event is InputEventJoypadButton and i.input_event is InputEventJoypadButton:
			if i.input_event.get_button_index() == input_event.get_button_index():
				return i
		if i.input_event is InputEventJoypadMotion and input_event is InputEventJoypadMotion:
			if i.input_event.get_axis() == input_event.get_axis() and i.input_event.get_axis_value() == input_event.get_axis_value():
				return i
	return JoypadButton.new()
