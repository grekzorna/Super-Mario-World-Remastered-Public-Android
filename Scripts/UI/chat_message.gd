extends Control

var message := ""
var sender := ""
var character: CharacterResource = null
var sender_id := 0

func _ready() -> void:
	print(character)
	var format_message := ""
	if sender_id == 1:
		modulate = Color.YELLOW
	if sender_id == -1:
		modulate = Color.RED
		sender = "(Server)"
		$MarginContainer/HBoxContainer/TextureRect.hide()
	if character != null:
		$MarginContainer/HBoxContainer/TextureRect.texture = character.HUDLetter
		$MarginContainer/HBoxContainer/TextureRect.show()
	format_message = sender + ": " + message
	$MarginContainer/HBoxContainer/Label.text = format_message
	SoundManager.play_ui_sound("res://Assets/Audio/SFX/map-spot.wav", randf_range(0.9, 1.2))
