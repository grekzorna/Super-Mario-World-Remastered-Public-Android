extends ParallaxBackground

@export var sprite_frames: SpriteFrames = null
@onready var sprite: AnimatedSprite2D = $ParallaxLayer/Sprite

func _ready() -> void:
	sprite.sprite_frames = sprite_frames
