extends Control

static var amount := 0

var colours := [Color("ffe7b5"), Color("e7b557")]

@export var unlocked := false
@export var achievement: Achievement = null

func _ready() -> void:
	amount += 1
	if amount % 2 == 0:
		$ColorRect.color = colours[0]
	else:
		$ColorRect.color = colours[1]
	if achievement == null:
		$HBoxContainer.modulate.a = 0
		return
	$HBoxContainer/VBoxContainer/Description.text = achievement.description
	if unlocked:
		$HBoxContainer/Icon.texture = achievement.icon
		$HBoxContainer/VBoxContainer/Title.text = achievement.title
		$HBoxContainer/VBoxContainer/Title.modulate = Color("ffff74")
