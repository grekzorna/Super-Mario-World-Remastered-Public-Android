extends StaticBody2D


var direction_vector := Vector2.UP
const move_speed := 64

var can_hit := false
var coin_placed: Coin = null

var amount := 0

@onready var raycasts: Node2D = $Raycasts

var queued_direction := Vector2.UP

var last_position := Vector2.ZERO

const COIN = preload("res://Instances/Prefabs/Items/coin.tscn")

func _ready() -> void:
	global_position.y -= 16
	spawn_coin()
	global_position = global_position.snapped(Vector2(8, 8))
	MusicPlayer.set_music_override(MusicPlayer.P_SWITCH)



func _on_timer_timeout() -> void:
	can_hit = true
	direction_vector = queued_direction
	global_position = global_position.snapped(Vector2(8, 8))
	spawn_coin()

func _physics_process(delta: float) -> void:
	global_position += (move_speed * direction_vector) * delta
	var collision = (move_and_collide((move_speed * direction_vector) * delta, true, 0))
	if is_instance_valid(collision):
		if collision.get_collider().global_position != last_position:
			kill()
	if Input.is_action_pressed("move_up_0"):
		if direction_vector == Vector2.DOWN:
			return
		queued_direction = Vector2.UP
	if Input.is_action_pressed("move_down_0"):
		if direction_vector == Vector2.UP:
			return
		queued_direction = Vector2.DOWN
	if Input.is_action_pressed("move_left_0"):
		if direction_vector == Vector2.RIGHT:
			return
		queued_direction = Vector2.LEFT
	if Input.is_action_pressed("move_right_0"):
		if direction_vector == Vector2.LEFT:
			return
		queued_direction = Vector2.RIGHT


func kill() -> void:
	if not can_hit:
		return
	MusicPlayer.stop_music_override(MusicPlayer.P_SWITCH)
	queue_free()

func spawn_coin() -> void:
	var coin_node = COIN.instantiate()
	last_position = global_position.snapped(Vector2(8, 8))
	coin_node.global_position = global_position.snapped(Vector2(8, 8))
	GameManager.current_level.add_child(coin_node)
	amount += 1
	if amount >= 64:
		kill()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Coin:
		if area.get_parent().global_position != last_position:
			kill()
