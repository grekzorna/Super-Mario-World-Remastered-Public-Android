extends AnimatableBody2D

@onready var fireballs := [$Fireball1, $Fireball2, $Fireball3, $Fireball4, $Fireball5, $Fireball6]

@export_enum("Left", "Right") var direction := 1

func _ready() -> void:
	if direction == 1:
		$Animation.play_backwards("Spin")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.damage()

func _physics_process(delta: float) -> void:
	if SettingsManager.sprite_settings.fireball == 1:
		for i in fireballs:
			i.global_rotation += 360 * delta
