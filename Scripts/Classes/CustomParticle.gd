class_name CustomParticle
extends Node2D

var longest_time := 1.0

func _ready() -> void:
	for i in get_children():
		if i is GPUParticles2D:
			if i.lifetime >= longest_time:
				longest_time = i.lifetime
			i.emitting = false
			await get_tree().process_frame
			i.emitting = true
	await get_tree().create_timer(longest_time, false).timeout
	queue_free()
