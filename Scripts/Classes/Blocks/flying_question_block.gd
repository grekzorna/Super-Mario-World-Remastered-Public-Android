extends Node2D

@export var continuous_flight := true
@export var item: PackedScene = null
@export var mushroom_if_small := true
@onready var quest_block: QuestionBlock = $"?Block"
@onready var wings: AnimatedSprite2D = $Wings

var flap_h := 0.0
var flap_v := 0.0

var h_speed := 1
var v_speed := 4

var h_mod := 64
var v_mod := 4

var moving := true

@onready var starting_position := global_position - Vector2(32, 0)

func _ready() -> void:
	quest_block.block_hitted.connect(block_hit)
	quest_block.item = item
	quest_block.mushroom_if_small = mushroom_if_small

func _physics_process(delta: float) -> void:
	if moving:
		flap_h += h_speed * delta
		flap_v += v_speed * delta
	if continuous_flight == false:
		global_position = starting_position + Vector2(sin(flap_h) * h_mod, sin(flap_v) * v_mod)
	elif moving:
		global_position.y = starting_position.y + sin(flap_v) * v_mod
		global_position.x -= 64 * delta

func block_hit() -> void:
	quest_block.reparent(get_parent())
	queue_free()
