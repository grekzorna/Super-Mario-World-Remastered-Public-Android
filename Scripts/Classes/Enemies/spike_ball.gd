extends Enemy
@onready var rotation_joint: Node2D = $RotationJoint
@onready var chain: Line2D = $Chain
@onready var animation: AnimationPlayer = $RotationJoint/Animation

@export var starting_direction := 1

func _ready() -> void:
	animation.speed_scale = starting_direction * 0.2
