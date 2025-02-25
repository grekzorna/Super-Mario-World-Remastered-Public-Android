extends CharacterBody2D

@export_enum("Goomba", "Bob-Omb", "Mushroom", "CheepCheep") var item := 0
@onready var scenes = [preload("res://Instances/Prefabs/Enemies/galoomba.tscn"), preload("res://Instances/Prefabs/Enemies/bob_omb.tscn"), preload("res://Instances/Prefabs/Items/mushroom_item.tscn"), preload("res://Instances/Prefabs/Enemies/cheep_cheep.tscn")]
const BUBBLE_BURST = preload("res://Instances/Particles/Misc/bubble_burst.tscn")
@onready var entity = scenes[item].instantiate()
var wave_amount := 0.0
var wave_speed := 2
var wave_height := 8
@onready var goomba_sprite: AnimatedSprite2D = $BubbleSprite/GoombaSprite
@onready var bob_omb_sprite: AnimatedSprite2D = $BubbleSprite/BobOmbSprite
@onready var mushroom_sprite: Sprite2D = $BubbleSprite/MushroomSprite
@onready var cheep_cheep_sprite: AnimatedSprite2D = $BubbleSprite/CheepCheepSprite

var hori_speed := 25

@onready var starting_y := global_position.y

func _ready() -> void:
	goomba_sprite.visible = item == 0
	bob_omb_sprite.visible = item == 1
	mushroom_sprite.visible = item == 2
	cheep_cheep_sprite.visible = item == 3
	if GameManager.autumn:
		$BubbleSprite/GoombaSprite.play("autumn")

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	if is_on_ceiling() or is_on_wall() or is_on_ceiling():
		burst()
	move_and_slide()

func burst() -> void:
	ParticleManager.summon_particle(BUBBLE_BURST, global_position)
	SoundManager.play_sfx(SoundManager.clap, self)
	summon_entity()

func handle_movement(delta: float) -> void:
	global_position.x -= hori_speed * delta
	wave_amount += wave_speed * delta
	global_position.y = starting_y + sin(wave_amount) * wave_height

func hitbox_hit(area: Area2D) -> void:
	if area.get_parent() is Player:
		var player: Player = area.get_parent()
		if Vector2.UP.dot((player.global_position - global_position).normalized()) > 0.25:
			player.bounce_off()
		burst()
	elif area.get_parent() is HeldObject:
		if area.get_parent().held == false:
			burst()
	elif area.get_parent() is PhysicsBody2D:
		burst()

func summon_entity() -> void:
	entity.global_position = global_position
	GameManager.current_level.add_child(entity)
	queue_free()
