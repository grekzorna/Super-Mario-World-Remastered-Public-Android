extends Node

var hitbox: Area2D = null

var velocity := 0.0

var sinking := false
@export var gravity := 5
var tilemap: TileMap = null

func _ready() -> void:
	for i in get_children():
		if i is Area2D:
			hitbox = i
			hitbox.area_entered.connect(sink)
			hitbox.global_position.y -= 2
		if i is TileMap:
			tilemap = i

func sink(area: Area2D) -> void:
	if area.get_parent() is Player:
		sinking = true

func _physics_process(delta: float) -> void:
	if sinking:
		velocity += gravity * delta
		tilemap.global_position.y += velocity * delta
