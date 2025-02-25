extends Node2D

var item: PlayerPowerUpState = null
@onready var item_preview: Sprite2D = $ItemPreview
@onready var block: Block = $Block
@onready var block_2: Block = $Block2
@onready var label: Label = $Label

@export var starting_item: PlayerPowerUpState = null
@export var can_cycle := false
var can_change := true

var power_ups := [preload("res://Resources/PlayerPowerUpState/Big.tres"), preload("res://Resources/PlayerPowerUpState/Cape.tres"), preload("res://Resources/PlayerPowerUpState/Fire.tres"), preload("res://Resources/PlayerPowerUpState/Ice.tres"), preload("res://Resources/PlayerPowerUpState/Propeller.tres"), preload("res://Resources/PlayerPowerUpState/Shell.tres"), preload("res://Resources/PlayerPowerUpState/Small.tres"), preload("res://Resources/PlayerPowerUpState/Raccoon.tres"), preload("res://Resources/PlayerPowerUpState/SuperBall.tres")]

var current_power_up := 0

func _ready() -> void:
	if starting_item != null:
		current_power_up = power_ups.find(starting_item)
		item = power_ups[current_power_up]
	if can_cycle == false:
		block.queue_free()
		block_2.queue_free()
		label.hide()

func _physics_process(delta: float) -> void:
	item_preview.show()
	if item == null:
		item_preview.hide()
		label.hide()
		return
	label.show()
	label.text = str(item.state_name)
	item_preview.texture = item.item_sprite
	item_preview.hframes = item_preview.texture.get_width() / 16
	item_preview.vframes = item_preview.texture.get_height() / 16

func cycle_item(direction := 1) -> void:
	if can_change == false:
		return
	can_change = false
	current_power_up += direction
	current_power_up = wrap(current_power_up, 0, power_ups.size())
	item = power_ups[current_power_up]
	await get_tree().create_timer(0.25, false).timeout
	can_change = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if item != null:
			area.get_parent().power_up(item)
