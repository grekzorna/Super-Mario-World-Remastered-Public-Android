extends CharacterBody2D

@export var time := 1
@onready var numbers: AnimatedSprite2D = $Numbers

var can_drop := false

var moving := false

func _ready() -> void:
	$Timer.wait_time = time - 1
	$Numbers.play(str(time))

func _physics_process(delta: float) -> void:
	if $Timer.is_stopped() == false:
		if int($Timer.time_left + 1) != 0:
			$Numbers.play(str(int($Timer.time_left + 1)))
		$Numbers.visible = int($Timer.time_left + 1) != 0
	if can_drop:
		velocity.y += 5
	elif moving:
		velocity.x = 50
	move_and_slide()

func drop() -> void:
	can_drop = true
	$Numbers.hide()

func activate() -> void:
	if moving:
		return
	moving = true
	$Timer.start()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().velocity.y > 0:
			activate()
