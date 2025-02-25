extends Node

var hitbox: Area2D = null


@export var rise_amount := 0.0
@export var speed := 5.0

var rising := false
var tilemap: TileMap = null

func _ready() -> void:
	for i in get_children():
		if i is Area2D:
			hitbox = i
			hitbox.area_entered.connect(rise)
			hitbox.global_position.y -= 2
		if i is TileMap:
			tilemap = i

func rise(area: Area2D) -> void:
	if rising == true:
		return
	if area.get_parent() is Player:
		rising = true
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(tilemap, "global_position:y", tilemap.global_position.y - rise_amount, speed)

