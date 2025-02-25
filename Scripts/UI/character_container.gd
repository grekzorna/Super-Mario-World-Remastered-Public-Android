class_name CharacterContainer
extends Control

@export var character: CharacterResource = null
@onready var char_sprite: Sprite2D = $Character
@onready var title: Sprite2D = $Title
@onready var character_script: Node = $CharacterScript

var skins := []

var index := 0

var selected := false
var hovered := false

func _ready() -> void:
	skins.push_front(character)
	set_character(character)

func _process(delta: float) -> void:
	index = wrap(index, 0, skins.size())
	title.texture = character.HUDTitle
	title.visible = hovered
	if hovered:
		pass
	if selected:
		char_sprite.texture = character.selection_selected
	else:
		char_sprite.texture = character.selection_idle
	if skins[index] != character:
		set_character(skins[index])

func set_character(char: CharacterResource) -> void:
	character = char
	if char.character_script != null:
		character_script.queue_free()
		character_script = Node.new()
		character_script.set_script(char.character_script)
		add_child(character_script)
