class_name WaterArea
extends CollisionShape2D

@onready var water_line: Line2D = $Line2D

@onready var water_rect: ColorRect = $WaterRest
@onready var hitbox: Area2D = $Hitbox

@export var top_textures: Array[Texture2D]

@export var current_speed := Vector2.ZERO

@export var water_colour := Color.WHITE
@onready var collision: CollisionShape2D = $Collision/CollisionShape2D
const WATER_SPLASH = preload("res://Instances/Particles/Misc/water_splash.tscn")

var frame := 0

func _ready() -> void:
	water_line.texture = top_textures[0]
	water_line.clear_points()
	add_top()
	add_hitbox_shape()
	water_rect.show()
	collision.shape = shape.duplicate()
	water_rect.color = water_colour

func add_top() -> void:
	water_line.add_point(Vector2(-shape.size.x / 2, (-shape.size.y / 2)), 0)
	water_line.add_point(Vector2(shape.size.x / (2 if current_speed == Vector2.ZERO else 1), (-shape.size.y / 2)), 1)
	water_rect.size = shape.size
	water_rect.position = -shape.size / 2
	water_line.position.y += 1

func _process(delta: float) -> void:
	water_rect.position = -shape.size / 2 + Vector2(0, 1)

func _physics_process(delta: float) -> void:
	water_line.position.x += current_speed.x * delta
	if water_line.position.x < -water_rect.size.x / 2:
		water_line.position.x = 0
	elif water_line.position.x > water_rect.size.x:
		water_line.position.x = water_rect.size.x / 2

func add_hitbox_shape() -> void:
	var collision = CollisionShape2D.new()
	collision.shape = shape.duplicate()
	hitbox.add_child(collision)

func summon_splash(splash_position: Vector2, node: Node2D) -> void:
	splash_position.y = to_global(water_line.get_point_position(0)).y
	splash_position.y
	ParticleManager.summon_particle(WATER_SPLASH, splash_position)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().water_enter(current_speed)
	var dist_from_top = abs(water_line.to_global(water_line.get_point_position(0)).y - area.global_position.y)
	if dist_from_top > 8:
		return
	if area.get_parent() is PhysicsBody2D:
		summon_splash(area.get_parent().global_position, area.get_parent())

func _on_hitbox_area_exited(area: Area2D) -> void:
	await get_tree().process_frame
	if is_instance_valid(area) == false:
		return
	if area.get_parent() is Player:
		area.get_parent().water_exit()
	var dist_from_top = abs(water_line.to_global(water_line.get_point_position(0)).y - area.global_position.y)
	if dist_from_top > 32:
		return
	if area.get_parent() is PhysicsBody2D:
		summon_splash(area.get_parent().global_position, area.get_parent())


func _on_timer_timeout() -> void:
	frame += 1
	frame = wrap(frame, 0, top_textures.size())
	water_line.width = top_textures[frame].get_height()
	$Line2D.texture = top_textures[frame]
