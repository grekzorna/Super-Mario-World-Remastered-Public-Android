extends Enemy

var moving := true

@export var can_throw_bone := false

var crumbled := false

@onready var ledge_detection: RayCast2D = $LedgeDetection
@onready var hitbox: Area2D = $Hitbox
@onready var bone_preview: VariationSprite = $Sprite/BonePreview
const DRY_BONES_BONE = preload("res://Instances/Prefabs/Projectiles/dry_bones_bone.tscn")
var can_hit := true

const classic_particles := [preload("res://Assets/Sprites/Enemys/DryBoneParts/ClassicHead.png"),
							preload("res://Assets/Sprites/Enemys/DryBoneParts/ClassicBone.png"),
							preload("res://Assets/Sprites/Enemys/DryBoneParts/ClassicBody.png"),
							null]

const maker_particles := [preload("res://Assets/Sprites/Enemys/DryBoneParts/MakerHead.png"),
						  preload("res://Assets/Sprites/Enemys/DryBoneParts/MakerBone.png"),
						  preload("res://Assets/Sprites/Enemys/DryBoneParts/MakerBody.png"),
						  null]

const MOVE_SPEED := 25
@onready var animations: AnimationPlayer = $Sprite/Animations

func _physics_process(delta: float) -> void:
	if moving:
		velocity.x = MOVE_SPEED * direction
	else:
		velocity.x  = 0
	ledge_detection.position.x = abs(ledge_detection.position.x) * direction
	ledge_detection.floor_normal = get_floor_normal()
	sprite.scale.x = -direction
	velocity.y += 15
	if is_on_wall():
		flip_direction()
	if ledge_detection.is_colliding() == false:
		if is_on_floor():
			flip_direction()
	move_and_slide()

func summon_gib() -> void:
	SoundManager.play_sfx(SoundManager.shatter, self)
	SoundManager.play_sfx(SoundManager.bone_crumble, self)
	if SettingsManager.sprite_settings.drybones == 0:
		ParticleManager.summon_four_part(classic_particles, global_position - Vector2(0, 16))
	else:
		ParticleManager.summon_four_part(maker_particles, global_position - Vector2(0, 16))

func melee_damage() -> void:
	die()

func damage() -> void:
	if not moving:
		return
	crumble()

func flip_direction() -> void:
	if can_hit:
		can_hit = false
	else:
		return
	direction *= -1
	await get_tree().create_timer(0.1, false).timeout
	can_hit = true

func throw_bone() -> void:
	if moving and can_throw_bone:
		moving = false
	else:
		return
	sprite.play("ThrowBone")
	bone_preview.show()
	await get_tree().create_timer(0.5, false).timeout
	if crumbled:
		return
	bone_preview.hide()
	summon_bone_projectile()
	await get_tree().create_timer(0.5, false).timeout
	if crumbled:
		return
	moving = true
	sprite.play("Walk")

func summon_bone_projectile() -> void:
	var node = DRY_BONES_BONE.instantiate()
	node.global_position = bone_preview.global_position
	node.direction = direction
	add_sibling(node)

func crumble() -> void:
	if crumbled == false:
		crumbled = true
		moving = false
	else:
		return
	$Hitbox/Shape.set_deferred("disabled", true)
	SoundManager.play_sfx(SoundManager.bone_crumble, self)
	sprite.play("Crumble")
	await get_tree().create_timer(4, false).timeout
	animations.play("Shake")
	await get_tree().create_timer(1, false).timeout
	sprite.play("Reassemble")
	animations.play("RESET")
	crumbled = false
	await sprite.animation_finished
	moving = true
	sprite.play("Walk")
	$Hitbox/Shape.set_deferred("disabled", false)
