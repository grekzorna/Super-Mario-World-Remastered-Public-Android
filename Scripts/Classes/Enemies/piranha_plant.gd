extends Enemy

var can_popup := true

func spawn() -> void:
	if GameManager.autumn:
		sprite.play("Autumn")
@onready var player_detect: Area2D = $PlayerDetect

func _physics_process(delta: float) -> void:
	if can_popup:
		if player_detect.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is Player) == false:
			can_popup = false
			$Animations.play("PopUp")
			await $Animations.animation_finished
			can_popup = true

func damage() -> void:
	die()

func hi() -> void:
	pass
