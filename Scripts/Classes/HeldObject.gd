class_name HeldObject
extends CharacterBody2D

@onready var sprite: Node2D = $Sprite
@onready var hitbox: Area2D = $Hitbox

@export var press_pickup := false
@export var directional_sprite := false ## Makes the sprite face its current direction
@export var yoshi_can_eat := true
@export var can_hurt_player := false
@export var can_destroy := false
@export var destructable := false
@export var kick_bounce := false
@export var land_bounce := true
@export var kickable := true
@export var player_can_destroy := false

@onready var gib = preload("res://Instances/Parts/enemy_gib.tscn")

@export var spit_item_override: PackedScene = null
@export var reward_life := false
var can_player_hit := true
var player: Player = null
var held := false

var player_thrown := false

@export var respawnable := false
var can_respawn := false
var respawn_timer := 10.0
var can_flip := true
var bounces_left := 0

var respawn_tilt := 0.0

@export var flip_animation := false
@export_file("*.tscn") var respawn_entity_scene := ""

var combo_vals := [100, 200, 400, 800, 1000, 2000, 4000, 8000, 0]

signal picked_up

var starting_rotation

'''
HI ME THIS IS NOTES ON HOW THE HELD ITEM SYSTEM WORKS IN player MAKER 2 BECAUSE IK YOUR GONNA FORGET IT

WHEN A HELD OBJECT IS MOVING, IT WILL DESTROY ANY ENEMIES IT TOUCHES, BUT WONT DESTROY ITSELF
WHEN A HELD OBJECT GOES INTO ANOTHER HELD OBJECT, IF THE HIT OBJECT IS MOVING, IT WILL DESTROY BOTH, ELSE IT WILL JUST DESTROY THE FIRST ONE
IF A HELD OBJECT GOES INTO EITHER AN ENEMY OR ANOTHER OBJECT, AND IS HELD, BOTH WILL GET DESTROYED

HOWEVER, STUFF LIKE P-SWITCHES THAT ARE NOT DESTRUCTABLE CANNOT DESTROY ANYTHING! AND CANNOT BE DESTROYED ITSELF!!!!!

IF player HITS A HELD OBJECT AND IS INVINCIBLE, IT WILL DESTROY THE OBJECT REGARDLESS OF IF HE CAN HOLD IT


~~~~ KICKING ~~~~

IF A HELD OBJECT ISNT SOLID, LIKE A POW BLOCK OR P-SWITCH, IT CANNOT BE KICKED
WHENEVER player IS TOUCHING A KICKABLE AND AFTER A COOLDOWN, THEY WILL BE KICKED IN playerS VELOCITY DIRECTION, NOT THE DIRECTION HES FACING
WHEN DROPPING AN OBJECT, IT WILL MOVE A LIL BIT, AND NO KICK NOISE WILL BE MADE

IF A NON KICKABLE LANDS ON playerS HEAD, IT WILL BOUNCE OFF THE SIDE IT IS MORE ON (BOUNCE TO THE RIGHT IF ON THE RIGHT HALF OF PLAYER)

WHEN player JUMPS ON A SHELL, IF IT IS MOVING HE WILL BOUNCE UP, ELSE HE WILL NOT!
WHEN player JUMPS ON A SHELL HE CANNOT PICK IT UP IF IT SPAWNS OR IF IT STOPPED MOVING (ACTIONS THAT MAKE player BOUNCE UP), CAN ONLY PICKUP ON DECENT!


OK THX ILY 
'''

var direction := 1

@export var player_can_stand := false

var position_direction := 1
var moving := false
var can_pickup := true
const gravity := 10
var combo := 1

var can_die := false

var velocity_lerp := Vector2.ZERO

func _ready() -> void:
	can_die = false
	can_player_hit = false
	spawn()
	can_pickup = false
	await get_tree().create_timer(0.25, false).timeout
	can_pickup = true
	can_player_hit = true
	can_die = true

func _physics_process(delta: float) -> void:
	if abs(velocity.x) > 50:
		moving = true
	elif not is_on_floor() and abs(velocity.y) > 50:
		moving = true
	else:
		moving = false
	if not can_destroy:
		can_hurt_player = false
	if player:
		position_direction = 1 if global_position.x > player.global_position.x else -1
	if respawnable:
		handle_respawn(delta)
	velocity_lerp = lerp(velocity_lerp, velocity, delta * 10)
	velocity.y += gravity
	velocity.y = clamp(velocity.y, -999, 275)
	if directional_sprite:
		sprite.scale.x = direction
	if is_on_floor() and not held and velocity.y > 0:
		velocity.x = lerpf(velocity.x, 0, delta * 10)
		if land_bounce:
			if bounces_left > 0:
				if bounces_left == 2:
					velocity.y = -100
				else:
					velocity.y = -50
				velocity.x /= 1.3
				bounces_left -= 1
	if is_on_wall() and not held:
		direction *= -1
		velocity.x = abs(velocity_lerp.x / 2) * get_wall_normal().x
	physics_update(delta)
	move_and_slide()
	check_for_collisions()

func _process(delta: float) -> void:
	#print(moving)
	if player_can_stand:
		set_collision_layer_value(1, not held and is_on_floor() and (not moving or hitbox.get_overlapping_areas().any(is_player) == false))
	if hitbox.get_overlapping_areas().any(is_player) and can_pickup:
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id))  and player_can_pickup(player):
			player.pickup_object(self)
	update(delta)

func add_combo() -> void:
	SoundManager.play_sfx(SoundManager.kick, self, 1 + (float(combo) / 10))
	if combo >= 8:
		SoundManager.play_global_sfx(SoundManager.one_up)
		GameManager.add_life(1, global_position)
		combo = 0
		return
	else:
		GameManager.add_score(combo_vals[combo], true, global_position)
	combo += 1

func hitbox_hit(area: Area2D) -> void: # Signal Function!!!
	var hit_node = area.owner
	if hit_node is Player:
		if can_player_hit == false:
			return
		if held:
			return
		player = hit_node
		if player.can_damage == false:
			return
		print(player.held_object)
		if not press_pickup:
			if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)) and can_pickup and player_can_pickup(player):
				player.pickup_object(self)
				return
		elif player.invincible and destructable:
			die()
			return
		elif player.attacking and destructable:
			die()
			return

		if player.global_position.y > global_position.y and velocity.y > 0 and player_can_stand:
			velocity.y = -100
			velocity.x = 100 * direction
			player.global_position.y -= 2
			return
		if Vector2.UP.dot(global_position.direction_to(player.global_position)) >= 0.5 and player.velocity.y > -50:
			if (player.spin_jumping or player.riding_yoshi) and destructable and not player_can_stand:
				spin_die()
			else:
				jumped_on()
	
		elif player.sliding and not moving and destructable:
			die()
		elif moving and can_hurt_player:
			player.damage()
		elif kickable:
			player.play_kick_animation()
			kick_forward()
		player_hit()
	elif hit_node is Fireball:
		hit_node.hit_solid()
		if destructable and player_can_destroy:
			die()
	elif (moving or velocity.y < -10) or held:
		if can_destroy:
			if hit_node is Enemy:
				if hit_node.can_held_item_damage:
					hit_node.die(false)
					add_combo()
					await get_tree().physics_frame
					if held and destructable:
						die()
			
			if hit_node is HeldObject:
				if hit_node == self:
					return
				if hit_node.destructable and can_player_hit:
					if hit_node.can_die:
						add_combo()
						hit_node.die()
						if held and destructable and Vector2.UP.dot(hit_node.global_position.direction_to(global_position)) >= 0.25:
							die()
					return

func die() -> void:
	if can_die == false:
		return
	summon_gib()
	SoundManager.play_sfx(SoundManager.kick, self)
	if player != null:
		if player.held_object == self:
			player.held_object = null
			player.holding = false
	held = false
	queue_free()

func check_for_collisions() -> void:
	var direction_strings = ["Up", "Down", "Left", "Right"]
	var direction_vectors = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var checks := 0
	for i in 4:
		var current_string: String = direction_strings[i]
		var current_vector: Vector2 = direction_vectors[i]
		var collision = move_and_collide(current_vector, true)
		if is_instance_valid(collision):
			if collision.get_collider() is Block:
				if is_valid_collision(collision, current_string):
					collision.get_collider().block_hit(current_string)
					return

func handle_respawn(delta: float) -> void:
	can_respawn = (abs(velocity.x) < 20 and abs(velocity.y) < 10) or held
	if can_respawn and respawn_timer >= 0:
		respawn_timer -= 1 * delta
	
	if respawn_timer <= 3 and can_respawn:
		respawn_tilt += 25 * delta
		sprite.rotation_degrees = sin(respawn_tilt) * 25
		respawn_tilt = wrap(respawn_tilt, 0, PI * 2)
	else:
		sprite.rotation_degrees = 0
	
	if respawn_timer <= 0 and can_respawn and can_flip:
		can_flip = false
		can_respawn = false
		if flip_animation:
			velocity.y = -200
			flip_tween()
			await get_tree().create_timer(0.5, false).timeout
		respawn_entity()


func player_can_pickup(player: Player) -> bool:
	var valid := false
	if not player.riding_yoshi and not player.holding and not player.carrying and player.can_pickup:
		if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
			valid = true
	
	return valid

func flip_tween() -> void:
	sprite.rotation_degrees = 180
	sprite.flip_v = false
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(sprite, "rotation_degrees", 0, 0.5)

func respawn_entity() -> void:
	sprite.global_rotation_degrees = 0
	print(respawn_entity_scene)
	var node = load(respawn_entity_scene).instantiate()
	node.global_position = global_position
	GameManager.current_level.add_child(node)
	queue_free()


func is_valid_collision(collision: KinematicCollision2D, direction_string := "") -> bool:
	var valid := false
	var collider = collision.get_collider()
	if held:
		return false
	if collider is Block:
		if player != null:
			collider.player = player
		else:
			collider.player = CoopManager.get_closest_player(global_position)
		if (direction_string == "Left" or direction_string == "Right") and collider.enable_side_hits:
			if abs(velocity_lerp.x) > 10:
				valid = true
		elif direction_string == "Up":
			if velocity.y < 15:
				SoundManager.play_sfx(SoundManager.bump, self)
				valid = true
	return valid

func summon_gib() -> void:
	var gib_node = gib.instantiate()
	gib_node.sprite = sprite.duplicate()
	gib_node.global_position = global_position
	gib_node.direction = direction
	get_parent().add_child(gib_node)

func is_player(area: Area2D) -> bool:
	if area.owner is Player:
		player = area.owner
	return area.owner is Player

func is_held_object(area: Area2D) -> bool:
	return area.owner is HeldObject

func is_enemy(area: Area2D) -> bool:
	return area.owner is Enemy

func let_go() -> void:
	if land_bounce:
		bounces_left = 2
	if test_move(global_transform.translated(Vector2(-8 * direction, 0)), Vector2(1 * direction, 0) * 8):
		global_position = player.global_position
	held = false

func kick_object() -> void:
	if land_bounce:
		bounces_left = 2
	can_player_hit = false
	player.summon_flash_particle(Vector2(8 * player.direction, -8))
	player.play_sfx("kick")
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
		kick_upward()
	else:
		kick_forward()
	await get_tree().physics_frame
	can_player_hit = true

func kick_upward() -> void:
	velocity.y = -350
	velocity.x = player.velocity.x / 2


func kick_forward() -> void:
	on_kick()
	velocity.y = 0
	var dir = direction
	if is_instance_valid(player):
		if player.input_direction != 0:
			dir = player.input_direction
		else:
			dir = player.facing_direction
	velocity.x = 100 * dir
	if kick_bounce:
		velocity.y = -100
	if is_instance_valid(player):
		velocity.x += (abs(player.velocity.x) * dir)

func spin_die() -> void:
	SoundManager.play_sfx(SoundManager.super_stomp, self)
	ParticleManager.summon_particle(ParticleManager.SPIN_IMPACT, global_position - Vector2(0, 16))
	GameManager.add_score(400, true, global_position)
	player.spin_bounce_off()
	queue_free()
	return

'''
Boilerplate Functions
'''
func spawn() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	pass

func on_kick() -> void:
	pass

func jumped_on() -> void:
	pass

func enemy_hit() -> void:
	pass

func object_hit() -> void:
	pass

func player_hit() -> void:
	pass
