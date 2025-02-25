extends Node2D

var float_meter := 60.0

var wave_prog := 0.0

signal life_dispensed

var coins_collected := 0
var coins_dispensed := 0
const ONEUP = preload("res://Instances/Prefabs/Items/1_up.tscn")
@onready var float_position = global_position.y - 128
const YOSHI_COIN = preload("res://Instances/Prefabs/Interactables/yoshi_coin.tscn")
func _physics_process(delta: float) -> void:
	float_meter -= 1 * delta
	wave_prog += 2 * delta
	if float_meter > 0:
		global_position.y = lerpf(global_position.y, float_position + sin(wave_prog) * 16, delta * 2)
	else:
		global_position.y -= 64 * delta
	global_position.x += 32 * delta

func summon_coin() -> void:
	coins_dispensed += 1
	var node = YOSHI_COIN.instantiate()
	node.global_position = global_position
	node.velocity.y = -150
	node.velocity.x = [-50, 50].pick_random()
	add_sibling(node)
	node.collected.connect(coin_collect)
	if coins_dispensed >= 12:
		float_meter = 0
		$Timer.queue_free()

func coin_collect() -> void:
	coins_collected += 1
	if coins_collected >= 10:
		dispense_life()

func dispense_life() -> void:
	if is_instance_valid($Timer):
		$Timer.queue_free()
	var node = ONEUP.instantiate()
	life_dispensed.emit()
	node.global_position = global_position
	node.velocity.y = -200
	add_sibling(node)
	SoundManager.play_sfx(SoundManager.item_sprout, self)
	await get_tree().create_timer(0.5, false).timeout
	float_meter = 0
