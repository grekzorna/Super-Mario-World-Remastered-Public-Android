extends Level

var island_tip := 0.0
@onready var island: AnimatableBody2D = $Island
@onready var center: Node2D = $Island/Center
@onready var iggy: CharacterBody2D = $Iggy
const CASTLE_1 = ("res://Instances/Levels/Cutscenes/Castle1.tscn")
var can_tip := true

var can_vic := true

var player_direction := 1

var player_center_distance := 0.0

var tip_speed := 1

var force_tip := false

var island_direction := 1

func ready_override() -> void:
	iggy.defeated.connect(victory)

func _process(delta: float) -> void:
	island_tip = clamp(island_tip, -32, 32)
	if center.global_position.x > player.global_position.x:
		player_direction = -1
	else:
		player_direction = 1
	player_center_distance = abs(abs(center.global_position.x) - abs(player.global_position.x))

func _physics_process(delta: float) -> void:
	island.rotation = lerp_angle(island.rotation, deg_to_rad(island_tip), tip_speed * delta)

func victory() -> void:
	CoopManager.boss_defeated(CASTLE_1)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if player.ground_pounding and player_center_distance > 48:
			island_tip = 32 * player_direction
			force_tip = true
			island_direction *= -1
			tip_speed = 3
			await get_tree().create_timer(0.25, false).timeout
			force_tip = false
			tip_speed = 1


func _on_timer_timeout() -> void:
	if force_tip:
		return
	if not can_tip:
		return
	island_direction *= -1
	island_tip = (8 * randi_range(1, 4)) * island_direction


func _on_iggy_defeated() -> void:
	victory()
