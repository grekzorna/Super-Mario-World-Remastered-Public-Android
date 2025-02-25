extends Node2D

var travel: float = 0.0
@onready var crystal_coin = preload("res://Instances/Prefabs/Items/crystal_coin.tscn")
@export var destination := Vector2.ZERO
@onready var start := global_position
@onready var sprite: AnimatedSprite2D = $Sprite
@export var jump_arc: Curve

@export var coin_resource: CrystalCoin = null

@export var teleport := false
@export var teleport_location := Vector2.ZERO

func _ready() -> void:
	await get_tree().process_frame
	SoundManager.play_sfx(SoundManager.coin_appear)

func _physics_process(delta: float) -> void:
	travel += 1 * delta
	travel = clamp(travel,0 , 1)
	global_position = lerp(start, destination, travel)
	if travel == 1:
		spawn_coin()
		queue_free()
	#print(sprite.offset.y)

func spawn_coin() -> void:
	var coin_node = crystal_coin.instantiate()
	coin_node.teleport = teleport
	coin_node.coin = coin_resource
	coin_node.teleport_location = teleport_location
	coin_node.global_position = global_position
	get_parent().add_child(coin_node)
