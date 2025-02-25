extends Node2D

@export var id := 1

static var current_point := 1

const sfxs := [null, ("res://Assets/Audio/SFX/1up1.mp3"), ("res://Assets/Audio/SFX/1up2.mp3"), ("res://Assets/Audio/SFX/1up3.mp3"), ("res://Assets/Audio/SFX/1up4.mp3")]

func _ready() -> void:
	$Sprite2D.hide()
	current_point = 1
	$PasserbyItem/Hitbox.area_entered.disconnect($PasserbyItem._on_hitbox_area_entered)

func _exit_tree() -> void:
	current_point = 1

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		if current_point == id:
			trigger()

func trigger() -> void:
	current_point += 1
	$Label.text = str(id)
	$Label/Animation.play("Collect")
	SoundManager.play_sfx(sfxs[id], self)
	if id == 4:
		$PasserbyItem.spawn_item()
