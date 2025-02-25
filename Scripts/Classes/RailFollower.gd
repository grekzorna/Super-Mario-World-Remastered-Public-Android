@icon("res://Assets/Sprites/Editor/Icons/Motor.png")
class_name RailFollower
extends CharacterBody2D

var current_rail: Rail = null

var destination_point: Vector2
var starting_point: Vector2

@export var move_speed := 16
@export var starting_direction := 1
@export var launch_multiplier := 1.0

@onready var starting_speed := move_speed

@onready var travel_direction = starting_direction

var direction_vector := Vector2.ZERO

var can_travel := true

var rail_point_index := 0

@onready var hitbox: Area2D = $Hitbox
@onready var travel_animation: AnimationPlayer = $TravelAnimation

@export var destination_travel_ratio := 0.0

var destinate_travel_prog := 0.0

var travelling := false

@onready var starting_position = global_position

var vardelta = 0
var position_lerp

var point_save := 0

signal destination_point_reached



func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	vardelta = delta
	if current_rail != null and travelling:
		destinate_travel_prog += move_speed * travel_direction * delta
		global_position = current_rail.to_global(current_rail.curve.sample_baked(destinate_travel_prog))
		var vector = (current_rail.curve.sample_baked(destinate_travel_prog + (delta)) - current_rail.curve.sample_baked(destinate_travel_prog)).normalized()
		if vector != Vector2.ZERO:
			direction_vector = vector
		if destinate_travel_prog > current_rail.curve.get_baked_length() or destinate_travel_prog <= 0:
			if current_rail.loop:
				if travel_direction == 1:
					destinate_travel_prog = 0
				else:
					destinate_travel_prog = current_rail.curve.get_baked_length()
			else:
				rail_end()
	if travelling:
		velocity = Vector2.ZERO
		if hitbox.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is Rail) == false:
			dismount_rail()
	else:
		velocity.y += 5
		velocity.y = clamp(velocity.y, -9999999, 200)
		if hitbox.get_overlapping_areas().any(is_rail):
			rail_enter()
	physics_update(delta)
	move_and_slide()

func physics_update(delta: float) -> void:
	pass

func get_starting_index() -> int:
	var current_position = current_rail.to_local(global_position)
	var shortest_point = current_rail.curve.get_closest_point(current_position)
	var points = current_rail.curve.get_baked_points()
	var closest_index = 0
	var min_distance = float(9999999999)  # Initialize with positive infinity
	
	for i in range(points.size() - 1):
		var point = points[i]
		if point.distance_to(current_position) <= min_distance:
			min_distance = point.distance_to(current_position)
			closest_index = i
	return closest_index

func get_starting_offset() -> float:
	return current_rail.curve.get_closest_offset(current_rail.to_local(global_position))


func rail_enter() -> void:
	travelling = true

	velocity = Vector2.ZERO
	travel_animation.speed_scale = 0
	move_speed = starting_speed
	destinate_travel_prog = current_rail.curve.get_closest_offset(current_rail.to_local(global_position))
	rail_travel()

func rail_travel() -> void:
	pass

func rail_end() -> void:
	if current_rail == null:
		dismount_rail()
	elif travel_direction == 1:
		if current_rail.ending_point_type == 0:
			dismount_rail()
		else:
			travel_direction *= -1
			rail_travel()
	elif travel_direction == -1:
		if current_rail.starting_point_type == 0:
			dismount_rail()
		else:
			travel_direction *= -1
			rail_travel()

func air_state(delta: float) -> void:
	pass

func is_rail(area: Area2D) -> bool:
	if area.get_parent() is Rail:
		if current_rail == area.get_parent():
			return false
		current_rail = area.get_parent()
	return area.get_parent() is Rail

func rail_travel_tween() -> void:
	travel_animation.speed_scale = (float(move_speed) / float(starting_point.distance_to(destination_point)))
	travel_animation.stop()
	travel_animation.play("Travel")
	await travel_animation.animation_finished
	

func dismount_rail() -> void:
	if current_rail.loop:
		if travel_direction == 1:
			rail_point_index = 0
		else:
			rail_point_index = current_rail.curve.get_baked_points().size() - 1
		rail_travel()
	else:
		travelling = false
		velocity = (direction_vector * (move_speed * travel_direction)) * launch_multiplier
		print(velocity)


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	point_save = rail_point_index


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	rail_point_index = point_save
