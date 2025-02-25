class_name LavaArea
extends CollisionShape2D

@onready var water_line: Line2D = $Line2D
@export var lava_colour := Color("b00000")
@onready var water_rect: ColorRect = $WaterRest
@onready var hitbox: Area2D = $Hitbox

@export var line_textures: Array[Texture2D] = []

@export var texture_speed := 0.1

var frame := 0

func _ready() -> void:
	if visible:
		water_rect.color = lava_colour
		water_line.width = line_textures[0].get_height()
		water_line.texture = line_textures[0]
		$Timer.start(texture_speed)
		add_top()
		water_rect.show()
	add_hitbox_shape()


func add_top() -> void:
	water_line.add_point(Vector2(-shape.size.x / 2, (-shape.size.y / 2) + 8), 0)
	water_line.add_point(Vector2(shape.size.x / 2, (-shape.size.y / 2) + 8), 1)
	water_rect.size = shape.size
	water_rect.position = -shape.size / 2 + Vector2(0, 16)

func add_hitbox_shape() -> void:
	var collision = CollisionShape2D.new()
	collision.shape = shape.duplicate()
	collision.position.y += 8
	hitbox.add_child(collision)

func summon_lava_particle(x_position := 0, node = null) -> void:
	var splash_position = Vector2(x_position, 0)
	splash_position.y = to_global(water_line.get_point_position(0)).y
	ParticleManager.summon_particle(ParticleManager.LAVA_SPLASH, splash_position)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().die(true)
	elif area.get_parent() is BoomBoomBoss:
		return
	elif area.get_parent() is Enemy:
		if area.get_parent().can_lava_swim == false:
			area.get_parent().queue_free()
	if area.get_parent() is PhysicsBody2D:
		SoundManager.play_sfx("res://Assets/Audio/SFX/podoboo.wav", area)
		summon_lava_particle(area.get_parent().global_position.x)

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.get_parent() is PhysicsBody2D:
		summon_lava_particle(area.get_parent().global_position.x, area.get_parent())

func _exit_tree() -> void:
	water_line.texture = null
	water_line.queue_free()


func _on_timer_timeout() -> void:
	frame += 1
	frame = wrap(frame, 0, line_textures.size())
	water_line.width = line_textures[frame].get_height()
	$Line2D.texture = line_textures[frame]
