class_name Dolphin
extends Enemy

@export_enum("Horizontal", "Vertical") var move_type := 0
@export_enum("Left", "Right", "Back and Forth") var horizontal_move_direction := 0

var bounce_height := 250
var hori_move_speed := 150
var back_forth_speed := 50
var move_speed := 0
var gravity := 5
var generated := false
var jumping := true
static var amount := 0

@onready var horizontal_collision: CollisionShape2D = $HorizontalCollision
@onready var vertical_collision: CollisionShape2D = $VerticalCollision

func _ready() -> void:
	if generated:
		amount += 1
		$VisibleOnScreenEnabler2D.screen_exited.connect(queue_free)
	amount = clamp(amount, 0, 999)
	if move_type == 0:
		vertical_collision.set_deferred("disabled", true)
		sprite.play("Horizontal")
		if horizontal_move_direction == 0:
			direction = -1
		else:
			direction = 1
	else:
		horizontal_collision.set_deferred("disabled", true)
		sprite.play("Vertical")
		direction = 0
	if SettingsManager.settings_file.edible_dolphins == false:
		yoshi_behavior = "None"

func _physics_process(delta: float) -> void:
	if horizontal_move_direction == 2:
		move_speed = back_forth_speed
	else:
		move_speed = hori_move_speed
	if abs(direction) == 1:
		sprite.scale.x = direction
	if jumping:
		velocity.y += gravity
	if global_position.y > 128:
		queue_free()
	can_damage = false
	move_and_slide()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is WaterArea:
		water_hit()

func _exit_tree() -> void:
	amount -= 1

func water_hit() -> void:
	velocity.y = 0
	if horizontal_move_direction == 2:
		velocity.x = 0
		jumping = false
		direction *= -1
		await get_tree().create_timer(0.5, false).timeout
	velocity.x = move_speed * direction
	jumping = true
	velocity.y = -bounce_height


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	if move_type == 0 and horizontal_move_direction != 2:
		queue_free()
