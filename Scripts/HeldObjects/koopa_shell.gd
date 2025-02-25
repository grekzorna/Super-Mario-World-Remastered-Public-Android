class_name KoopaShell
extends Shell

@onready var fire_breath = preload("res://Instances/Prefabs/Projectiles/fire_breath.tscn")
@export_enum("Red", "Green", "Yellow", "Purple") var colour := 0
@onready var skid_particles: GPUParticles2D = $Skid
@onready var autumn_sprite: Sprite2D = $AutumnSprite

@onready var animations: AnimationPlayer = $Sprite/Animations
@onready var autumn_animations: AnimationPlayer = $AutumnSprite/Animations

var koopa_scene = ("res://Instances/Prefabs/Enemies/koopa_troopa.tscn")
const FIRE_BREATH = preload("res://Instances/Prefabs/Projectiles/fire_breath.tscn")

func spawn() -> void:
	held = false
	sprite.texture = get_sprite()
	autumn_sprite.texture = get_autumn_sprite()
	if colour == 0:
		spit_item_override = FIRE_BREATH
	respawnable = entity_present
	if GameManager.autumn:
		sprite.hide()
		autumn_sprite.show()
		sprite = autumn_sprite
		animations = autumn_animations
	else:
		autumn_sprite.hide()

func physics_update(delta: float) -> void:
	if shell_moving:
		if entity_present:
			animations.play("SpinEntity")
		else:
			animations.play("Spin")
		if skid_particles:
			skid_particles.emitting = is_on_floor()
	else:
		if skid_particles:
			skid_particles.emitting = false
		if entity_present:
			animations.play("IdleEntity")
		else:
			animations.play("Idle")
	if entity_present:
		handle_respawn(delta)
	sprite.flip_v = flipped
	handle_movement(delta)

func respawn_entity() -> void:
	print(respawn_entity_scene)
	var node = load(respawn_entity_scene).instantiate()
	node.global_position = global_position - Vector2(0, 1)
	node.colour = colour
	GameManager.current_level.add_child(node)
	node.velocity.y = -200
	node.velocity.x = -50 * direction
	entity_present = false
	sprite.global_rotation = 0
	respawnable = false

func flip_tween() -> void:
	sprite.rotation_degrees = 180
	sprite.flip_v = false
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(sprite, "rotation_degrees", 0, 0.5)

func _on_koopa_pickup_range_area_entered(area: Area2D) -> void:
	if area.get_parent() is ShelllessKoopa and not moving and not held and not entity_present:
		area.get_parent().entering_shell = self
		area.get_parent().shell_interaction()


func get_sprite() -> Texture:
	var sprites = [preload("res://Assets/Sprites/Enemys/Koopas/KoopaShells/Red.png"), 
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaShells/Green.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaShells/Yellow.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/KoopaShells/Blue.png"),]
	return sprites[colour]

func get_autumn_sprite() -> Texture2D:
	var sprites = [preload("res://Assets/Sprites/Enemys/Koopas/Masks/Red.png"), 
					preload("res://Assets/Sprites/Enemys/Koopas/Masks/Green.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/Masks/Yellow.png"),
					preload("res://Assets/Sprites/Enemys/Koopas/Masks/Blue.png"),
					null,
					null]
	return sprites[colour]
