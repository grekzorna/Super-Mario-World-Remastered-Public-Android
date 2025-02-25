extends HeldObject

@onready var autumn_sprite: AnimatedSprite2D = $AutumnSprite

func spawn() -> void:
	autumn_sprite.visible = GameManager.autumn
	if GameManager.autumn:
		sprite.hide()
		sprite = autumn_sprite
