extends Node2D

@export var textures = [null, null, null, null]
@onready var parts = [$"1", $"2", $"3", $"4"]

var speed := 50
var can_move := true
var rotation_speed := 720
var part_rotation := 0.0
var part_directions := [-1, -1, 1, 1]
var part_velocity := [Vector2(-speed, -speed * 2), Vector2(-speed, -speed), Vector2(speed, -speed * 2), Vector2(speed, -speed)]
var sprite_size := 8

func _ready() -> void:
	print(sprite_size)
	var part_index := 0
	for i in parts:
		var texture = textures[part_index]
		var sprite: Sprite2D = i.get_node("Sprite")
		sprite.texture = texture
		if is_instance_valid(texture):
			var h_frames = texture.get_width() / sprite_size
			h_frames = clamp(h_frames, 1, 9999)
			sprite.hframes = h_frames
			var v_frames = texture.get_height() / sprite_size
			v_frames = clamp(v_frames, 1, 9999)
			sprite.vframes = v_frames
		sprite.frame = randi_range(0, (sprite.hframes * sprite.vframes) - 1)
		i.velocity = part_velocity[part_index]
		part_index += 1
	await get_tree().create_timer(5, false).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	var part_index := 0
	part_rotation += rotation_speed * delta
	part_rotation = wrap(part_rotation, 0, 360)
	for i in parts:
		i.velocity.y += 10
		if can_move:
			i.move_and_slide()
		i.rotation_degrees = snapped(part_rotation * part_directions[part_index], 45)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
