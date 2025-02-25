extends Sprite2D
@onready var item_spawn_location: Marker2D = $ItemSpawnLocation
@onready var item_animation: AnimationPlayer = $AnimationPlayer
var item = ""
var item_holder = self
var direction = 1
var player: Player = null
@onready var mushroom_scene = preload("res://Instances/Prefabs/Items/mushroom_item.tscn")
@onready var star_scene = preload("res://Instances/Prefabs/Items/starman.tscn")
@onready var flower_scene = preload("res://Instances/Prefabs/Items/fire_flower.tscn")
@onready var feather_scene = preload("res://Instances/Prefabs/Items/cape_feather.tscn")
@onready var mushroom_sprite = preload("res://Assets/Sprites/Mushroom.png")
@onready var star_sprite = preload("res://Assets/Sprites/StarMan.png")
@onready var flower_sprite = preload("res://Assets/Sprites/FireFlowerSheet.png")

func _ready() -> void:
	hide()
	await owner.ready
	match item:
		"Mushroom":
			item_holder.texture = mushroom_sprite
		"Star":
			item_holder.texture = star_sprite
		"Flower":
			item_holder.texture = flower_sprite
	item_holder.hframes = item_holder.texture.get_width() / 16

func do_hit() -> void:
	show()
	if item != "Coin":
		SoundManager.play_sfx(SoundManager.item_sprout)
		if item != "Cape":
			item_holder.show()
			item_animation.play("ItemEmerge")
			await get_tree().create_timer(0.5, false).timeout
			spawn_item()
		else:
			spawn_feather()
	else:
		self_modulate.a = 0
		item_animation.play("RESET")
		item_animation.play("CoinEmerge")
		GameManager.hud.add_coins(1)

func spawn_feather() -> void:
	var feather_node = feather_scene.instantiate()
	get_parent().get_parent().add_child(feather_node)
	feather_node.global_position = global_position - Vector2(0, 16)
	feather_node.velocity.y = -400

func spawn_item() -> void:
	match item:
		"Mushroom":
			var mushroom_node = mushroom_scene.instantiate()
			mushroom_node.global_position = item_spawn_location.global_position
			mushroom_node.direction = direction
			get_parent().get_parent().add_child(mushroom_node)
		"Star":
			var star_node = star_scene.instantiate()
			star_node.global_position = item_spawn_location.global_position
			star_node.direction = direction
			get_parent().get_parent().add_child(star_node)
		"Flower":
			var flower_node = flower_scene.instantiate()
			flower_node.global_position = item_spawn_location.global_position
			get_parent().get_parent().add_child(flower_node)
		
	item_holder.hide()
