extends Block

@export_enum("Mushroom", "Flower", "Star") var wheel_choice := "Mushroom"

var offset := 0.0
@onready var animations: AnimationPlayer = $Sprite/Items/Animation

@export var center := false

func spawn() -> void:
	if center:
		var choice = ["Mushroom", "Flower", "Star"].pick_random()
		$Sprite/Items/Animation.play(choice)
		wheel_choice = choice
		can_hit = false
		
	else:
		await get_tree().physics_frame
		print(offset)
		$Sprite/Items/Animation.play("Spin")
		$Sprite/Items/Animation.seek(offset)

func block_hit_override(direction := "Up") -> void:
	if can_hit == false:
		return
	can_hit = false
	$Sprite/Items/Animation.play(wheel_choice)
	SoundManager.play_sfx(SoundManager.switch_activate, self)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		var player: Player = area.owner
		if Vector2.DOWN.dot((player.global_position - global_position)) > 0.5 and player.velocity.y < 0:
			player.velocity.y = 15
			player.bump_ceiling()
			block_hit("Up")
			$Hitbox.queue_free()
