extends CharacterBody2D

var can_fall := false


func _ready() -> void:
	MusicPlayer.play_dead()
	get_tree().paused = true
	await get_tree().create_timer(0.5).timeout
	velocity.y = -200
	can_fall = true
	await get_tree().create_timer(2.5).timeout
	TransitionManager.reload_level()

func _physics_process(_delta: float) -> void:
	if can_fall:
		velocity.y += 10
	move_and_slide()
