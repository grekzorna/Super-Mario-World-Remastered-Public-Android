extends Enemy


@export var ropeLength = 30
@export var constrain = 1	# distance between points
@export var gravity = Vector2(0,9.8)
@export var dampening = 0.9
@export var startPin = true
@export var endPin = true

@onready var line2D: = $Line2D

@onready var chain: Node = $Chain

var bounces_left := 2

var pos: PackedVector2Array
var posPrev: PackedVector2Array
var pointCount: int

var chasing := true
var charging := false

var loose := false

func _ready()->void:
	$Post.global_position = global_position
	var pos_save = global_position
	pointCount = get_pointCount(ropeLength)
	resize_arrays()
	init_position()

func get_pointCount(distance: float)->int:
	return int(ceil(distance / constrain))

func resize_arrays():
	pos.resize(pointCount)
	posPrev.resize(pointCount)

func init_position()->void:
	for i in range(pointCount):
		pos[i] = position + Vector2(constrain *i, 0)
		posPrev[i] = position + Vector2(constrain *i, 0)

func _process(delta)->void:
	handle_chain(delta)

func handle_chain(delta: float) -> void:
	update_points(delta)
	update_constrain()
	set_last(global_position)
	if not loose:
		set_start($Post.global_position)
	#update_constrain()	#Repeat to get tighter rope
	#update_constrain()
	
	# Send positions to Line2D for drawing
	var index := 0
	var chain_index := 0
	for i in pos:
		if index % chain.get_children().size() == 0:
			chain.get_child(chain_index).global_position = i
			chain_index += 1
		index += 1
		if chain_index >= chain.get_children().size():
			break
	for i in chain.get_children():
		i.move_and_slide()

func _physics_process(delta: float) -> void:
	if chasing:
		handle_idle()
	elif charging:
		handle_charging()
	move_and_slide()

func handle_charging() -> void:
	var target_player = CoopManager.get_closest_player(global_position)
	var target_position = $Post.global_position + ($Post.global_position.direction_to(target_player.global_position - Vector2(0, 8)) * 64)
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
	sprite.scale.x = -direction
	sprite.rotation = global_position.angle_to(target_position) * direction
	velocity.x = 0
	velocity.y += 15

func handle_idle() -> void:
	if is_on_wall() or ($Sprite/RayCast2D.is_colliding() == false and not loose):
		direction *= -1
	if is_on_floor():
		bounces_left -= 1
		if bounces_left <= 0:
			if not loose:
				direction *= -1
			bounces_left = 2
		if loose:
			velocity.y = -200
		else:
			velocity.y = -150
	if loose:
		velocity.x = 125 * direction
	else:
		velocity.x = 75 * direction
	velocity.y += 10
	sprite.scale.x = -direction

func set_start(p:Vector2)->void:
	pos[0] = p
	posPrev[0] = p

func set_last(p:Vector2)->void:
	pos[pointCount-1] = p
	posPrev[pointCount-1] = p

func update_points(delta)->void:
	for i in range (pointCount):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=pointCount-1) || (i==0 && !startPin) || (i==pointCount-1 && !endPin):
			var velocity = (pos[i] -posPrev[i]) * dampening
			posPrev[i] = pos[i]
			pos[i] += velocity + (gravity * delta)

func update_constrain()->void:
	for i in range(pointCount):
		if i == pointCount-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		
		# if first point
		if i == 0:
			if startPin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		# if last point, skip because no more points after it
		elif i == pointCount-1:
			pass
		# all the rest
		else:
			if i+1 == pointCount-1 && endPin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().ground_pounding:
			destroy_post()


func lunge_at_player() -> void:
	charging = false
	var target_player = CoopManager.get_closest_player(global_position)
	var target_position = $Post.global_position + ($Post.global_position.direction_to(target_player.global_position) * 64)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position", target_position, 0.25)
	await get_tree().create_timer(1, false).timeout
	sprite.rotation = 0
	if $Post.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
	if not loose:
		tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "global_position", $Post.global_position, 0.3)
		await tween.finished
	bounces_left = 2
	chasing = true
	charging = false
	$Timer.start()

func destroy_post() -> void:
	loose = true
	startPin = false
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Post, "global_position:y", $Post.global_position.y + 16, 0.2)
	await tween.finished
	$Post/CollisionShape2D.queue_free()


func _on_timer_timeout() -> void:
	if loose:
		return
	charging = true
	chasing = false
	await get_tree().create_timer(1, false).timeout
	lunge_at_player()
