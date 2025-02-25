extends Enemy

var target_player: Player = null
var teleporting := false
@onready var position_cast: RayCast2D = $CastJoint/PositionCast
@onready var cast_joint: Node2D = $CastJoint
@onready var ceiling_check: RayCast2D = $CastJoint/CeilingCheck

@export var can_respawn := false

var can_clone := false

const MAGIKOOPA_PROJECTILE = preload("res://Instances/Prefabs/Enemies/magikoopa_projectile.tscn")
func _physics_process(delta: float) -> void:
	target_player = CoopManager.get_closest_player(global_position)
	if teleporting:
		cast_joint.global_position = target_player.global_position + Vector2(randi_range(128, 230) * target_player.facing_direction, 0)
		
		if position_cast.is_colliding():
			global_position = position_cast.get_collision_point()
	if global_position.x > target_player.global_position.x:
		direction = 1
	else:
		direction = -1
	sprite.scale.x = direction

func _ready() -> void:
	if can_respawn:
		gib_type = 2
	hide()
	$README.hide()
	teleporting = true
	await get_tree().create_timer(3, false).timeout
	can_clone = true
	loop()

func damage() -> void:
	die()

func die(add_score := true) -> void:
	if can_respawn:
		summon_clone()
	SoundManager.play_sfx(SoundManager.kick, self)
	summon_gib()
	queue_free()

func summon_clone() -> void:
	if can_clone == false:
		return
	can_clone = false
	var node = load(self.scene_file_path).instantiate()
	node.can_respawn = true
	node.global_position = Vector2(0, 0)
	add_sibling(node)

func loop() -> void:
	teleporting = true
	await get_tree().create_timer(1, false).timeout
	show()
	$Animations.play_backwards("Warp")
	show()
	SoundManager.play_sfx(SoundManager.magic, self)
	teleporting = false
	await get_tree().create_timer(1, false).timeout
	$Animations.play("Shoot")
	await get_tree().create_timer(2.5, false).timeout
	$Animations.play("Warp")
	SoundManager.play_sfx(SoundManager.magic, self)
	await get_tree().create_timer(1, false).timeout
	loop()

func shoot() -> void:
	var node = MAGIKOOPA_PROJECTILE.instantiate()
	node.global_position = $Sprite/ShootPosition.global_position
	node.direction = node.global_position.direction_to(target_player.global_position - Vector2(0, 8))
	add_sibling(node)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()
