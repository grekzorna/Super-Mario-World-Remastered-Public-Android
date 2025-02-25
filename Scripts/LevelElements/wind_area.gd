@tool
extends CollisionShape2D

@onready var particles: GPUParticles2D = $Particles
@onready var area: Area2D = $Area

@export var wind_speed := Vector2.UP

func _ready() -> void:
	area.get_node("Shape").shape = shape

func _physics_process(delta: float) -> void:
	for i in area.get_overlapping_areas():
		if i.get_parent() is CharacterBody2D:
			i.get_parent().velocity -= wind_speed
