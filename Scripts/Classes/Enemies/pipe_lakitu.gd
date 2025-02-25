extends Enemy

@export var attack_item: PackedScene = null
@onready var player_detect: Area2D = $PlayerDetect

var can_popup := true

func throw_item() -> void:
	SoundManager.play_sfx("res://Assets/Audio/SFX/hammer-bro-throw.wav", self)
	var node = attack_item.instantiate()
	var throw_direction := direction
	node.global_position = global_position
	if node is Enemy or node is HeldObject:
		node.direction = throw_direction
	if node is CharacterBody2D:
		node.velocity.x = 150 * throw_direction
		node.velocity.y = -250
	GameManager.current_level.add_child(node)

func damage() -> void:
	die()

func _physics_process(delta: float) -> void:
	sprite.scale.x = direction
	var target_player: Player = CoopManager.get_closest_player(global_position)
	direction = 1
	if target_player.global_position.x < global_position.x:
		direction = -1
	if can_popup:
		if player_detect.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is Player) == false:
			can_popup = false
			$MainAnimation.play("PopUp")
			await $MainAnimation.animation_finished
			can_popup = true
