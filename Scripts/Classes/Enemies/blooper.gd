extends Enemy

var falling := true
var can_rise := true

var target_player: Player = null
@onready var start_x := global_position.x
var wave := 0.0

var tween: Tween = null

func _physics_process(delta: float) -> void:
	target_player = CoopManager.get_closest_player(global_position)
	direction = sign(target_player.global_position.x + 1 - global_position.x)
	wave += 8 * delta
	wave = wrap(wave, 0, 2 * PI)
	if falling:
		global_position.x = start_x + sin(wave) * 2
		global_position.y += 32 * delta
		$Sprite.play("Fall")
		if global_position.y >= target_player.global_position.y and can_rise:
			can_rise = false
			falling = false
			rise_tween()
			$Sprite.play("Rise")

func on_yoshi_tongue_grab() -> void:
	tween.stop()

func damage() -> void:
	die()

func rise_tween() -> void:
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", global_position + Vector2(64 * direction, -64), 0.75)
	await tween.finished
	start_x = global_position.x
	falling = true
	await get_tree().create_timer(0.2, false).timeout
	can_rise = true
