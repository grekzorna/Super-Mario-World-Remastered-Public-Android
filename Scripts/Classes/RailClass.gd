@icon("res://Assets/Sprites/Editor/Icons/Rail.png")
class_name Rail
extends Path2D

@export_enum("Drop", "Bounce", "Motor") var starting_point_type := 0
@export_enum("Drop", "Bounce", "Motor") var ending_point_type := 0
@export var loop := false
@export var custom_rail_texture: Texture2D = null

@onready var hitbox: Area2D = $Hitbox
@onready var line_visual: Line2D = $LineVisual

@onready var joint: Node2D = $Follow/Joint
@onready var follow: PathFollow2D = $Follow

var activated := true

@onready var start_motor: AnimatedSprite2D = $StartMotor
@onready var end_motor: AnimatedSprite2D = $EndMotor

@onready var start_bounce: Sprite2D = $BounceStart
@onready var end_bounce: Sprite2D = $BounceEnd

func _ready() -> void:
	var point_index := 0
	for i in curve.point_count:
		curve.set_point_in(point_index, Vector2i(curve.get_point_in(point_index)).snapped(Vector2(16, 16)))
		curve.set_point_out(point_index, Vector2i(curve.get_point_out(point_index).snapped(Vector2(16, 16))))
		print(curve.get_point_in(point_index))
		point_index += 1
	generate_rail_hitbox()
	generate_line_visual()
	end_visuals_setup()


func _process(delta: float) -> void:
	hitbox.monitorable = visible
	hitbox.monitoring = visible

func end_visuals_setup() -> void:
	var points = curve.get_baked_points()
	start_motor.position = Vector2i(points[0])
	end_motor.position = Vector2i(points[points.size() - 1])
	
	start_motor.visible = starting_point_type == 2
	end_motor.visible = ending_point_type == 2
	
	start_bounce.position =  Vector2i(points[0])
	end_bounce.position =  Vector2i(points[points.size() - 1])
	
	start_bounce.visible = starting_point_type == 1
	end_bounce.visible = ending_point_type == 1

func generate_rail_hitbox() -> void:
	var point_index := 0
	var points = curve.get_baked_points()
	for i in points.size() - 1:
		var collision_shape = CollisionShape2D.new()
		var segment = SegmentShape2D.new()
		segment.a = points[point_index]
		segment.b = points[point_index + 1]
		collision_shape.shape = segment
		hitbox.add_child(collision_shape)
		point_index += 1

func generate_line_visual() -> void:
	if is_instance_valid(custom_rail_texture):
		line_visual.texture = custom_rail_texture
		line_visual.width = custom_rail_texture.get_height()
		line_visual.default_color = Color.WHITE
	for i in curve.get_baked_points():
		line_visual.add_point(i)
