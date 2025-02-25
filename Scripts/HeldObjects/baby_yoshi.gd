extends HeldObject

var object_eaten: Node = null
const ADULT_YOSHI = preload("res://Instances/Prefabs/Interactables/yoshi.tscn")

@export_enum("Green", "Red", "Blue", "Yellow") var colour := 0

var amount_eaten := 0

const textures := [preload("res://Assets/Sprites/Characters/Yoshi/BabyYoshis/Green.png"), 
					preload("res://Assets/Sprites/Characters/Yoshi/BabyYoshis/Red.png"),
					preload("res://Assets/Sprites/Characters/Yoshi/BabyYoshis/Blue.png"),
					preload("res://Assets/Sprites/Characters/Yoshi/BabyYoshis/Yellow.png")]

func spawn() -> void:
	$Sprite.texture = textures[colour]

func physics_update(delta: float) -> void:
	if not held:
		if is_on_floor():
			velocity.x /= 2
			velocity.y = -100

func eat_object(object: Node) -> void:
	if is_instance_valid(object):
		object_eaten = object
		$Sprite/ObjectPoint.remote_path = $Sprite/ObjectPoint.get_path_to(object)
	$Animations.play("Eat")
	await $Animations.animation_finished
	swallow_object()

func swallow_object() -> void:
	if is_instance_valid(object_eaten):
		if object_eaten is PowerUp:
			amount_eaten += 5
		amount_eaten += 1
		object_eaten.queue_free()
		SoundManager.play_sfx(SoundManager.yoshi_gulp, self)
		$Animations.play("Swallow")
		$Sprite/ObjectPoint.remote_path = ""
		if amount_eaten >= 5:
			mature()

func mature() -> void:
	var node =  ADULT_YOSHI.instantiate()
	node.colour = colour
	node.global_position = global_position
	add_sibling(node)
	SoundManager.play_sfx(SoundManager.yoshi_mount, self)
	node.play_hatch_animation()
	queue_free()

func _on_eat_box_area_entered(area: Area2D) -> void:
	if is_instance_valid(object_eaten):
		return
	if area.get_parent() is Enemy:
		if area.get_parent().yoshi_behavior != "None":
			area.get_parent().is_yoshi_item = true
			eat_object(area.get_parent())
	elif area.get_parent() is PowerUp:
		area.get_parent().can_grab = false
		eat_object(area.get_parent())
