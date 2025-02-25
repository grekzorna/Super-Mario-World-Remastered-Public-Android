extends StaticBody2D
@onready var collision_polygon: CollisionPolygon2D = $Collision

@export var speed := 64
@export var length := 16
@export var vertical_direction := -1
@onready var sprite_1: AnimatedSprite2D = $Sprite1
@onready var motor_1: AnimatedSprite2D = $Motor1
@onready var motor_2: AnimatedSprite2D = $Motor2

func _ready() -> void:
	setup_collision()
	var sprite_speed_scale = speed / 1.25
	sprite_1.speed_scale = sprite_speed_scale * -vertical_direction
	setup_visuals()
	sprite_1.hide()
	motor_1.speed_scale = sprite_speed_scale / 5
	motor_2.speed_scale = sprite_speed_scale / 5
	motor_2.position = Vector2(length, length * vertical_direction)
	constant_linear_velocity = Vector2(speed, speed * vertical_direction)
	
func setup_collision() -> void:
	collision_polygon.polygon[1] = Vector2(length, 0)
	if vertical_direction == 1:
		collision_polygon.polygon[1] = Vector2(0, length)
	collision_polygon.polygon[2] = Vector2(length, -length * -vertical_direction)

func setup_visuals() -> void:
	var index := 0
	for i in length / 8:
		var new_vis = sprite_1.duplicate()
		new_vis.position = Vector2(4, 4) + (Vector2(index, index * vertical_direction) * 8)
		if vertical_direction == 1:
			new_vis.position.y += 8
		new_vis.scale.x = -vertical_direction
		add_child(new_vis)
		index += 1
		
