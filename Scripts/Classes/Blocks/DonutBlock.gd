extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite

var timer := 0.0

@export var falling := false

var stood_on := false
var respawn_pos := Vector2.ZERO

func _physics_process(delta: float) -> void:
	stood_on = $Area2D.get_overlapping_areas().any(is_player)
	
	if not falling:
		if not stood_on:
			$AnimationPlayer.play("Idle")
		else:
			$AnimationPlayer.play("Shake")
	
	if falling:
		global_position.y += 128 * delta
	
	if timer >= 1:
		falling = true

func is_player(area: Area2D) -> bool:
	if area.owner is Player:
		return area.owner.is_on_floor()
	else:
		return false

func falling_start() -> void:
	respawn_pos = global_position
	$RespawnTimer.start()

func _on_respawn_timer_timeout() -> void:
	falling = false
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
	global_position = respawn_pos
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
