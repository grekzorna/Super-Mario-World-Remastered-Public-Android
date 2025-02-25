extends Enemy

@export var initial_jump_height := -200
@export var horizontal_speed := 150
@export var varying_mod := false

var spawned := false

@export var starting_direction := 1

func spawn() -> void:
	if spawned:
		$VisibleOnScreenEnabler2D.queue_free()
	direction = starting_direction
	$Sprite.scale.x = direction
	jump()

func damage() -> void:
	die()

func _physics_process(delta: float) -> void:
	velocity.x = horizontal_speed * direction
	velocity.y += 5
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is WaterArea:
		jump()

func jump() -> void:
	velocity.y = initial_jump_height - (randi_range(0, 150) if varying_mod else 0)
