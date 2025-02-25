extends Level
const MECHA_KOOPA_ASSEMBLY_PART = preload("res://Instances/Parts/mecha_koopa_assembly_part.tscn")
@onready var spawn_location: Node2D = $SpawnLocation
@onready var conveyor: StaticBody2D = $Conveyor
@onready var conveyor_sprites = $Conveyor/Sprites.get_children()
var assembly_running := true
@onready var assembly_timer: Timer = $AssemblyTimer
@onready var animation: AnimationPlayer = $Animation

@onready var presses = [$AssemblyPress, $AssemblyPress2, $AssemblyPress3]

var broken := false

const BLOCK_BREAK = preload("res://Assets/Sprites/Particles/BlockBreak.png")

func _on_despawn_area_entered(area: Area2D) -> void:
	area.get_parent().queue_free()

func break_stuff() -> void:
	broken = true
	MusicPlayer.game.stop()
	assembly_running = true
	$SpawnTimer.wait_time = 0.1
	$SpawnTimer.start()
	animation.play("Grow")
	for i in CoopManager.active_players.values():
		i.direction = -1
		i.state_machine.transition_to("Freeze")
	for i in presses:
		i.get_node("AnimationPlayer").speed_scale = 5
	await get_tree().create_timer(3).timeout
	$SpawnTimer.stop()
	await get_tree().create_timer(3).timeout
	
	conveyor_collapse()
	animation.play("Fall")
	SoundManager.play_ui_sound(SoundManager.boss_fall)
	for i in presses:
		i.get_node("AnimationPlayer").stop()
	await get_tree().create_timer(1).timeout
	CoopManager.boss_defeated()
	await get_tree().create_timer(10).timeout
	TransitionManager.transition_to_map(GameManager.current_map_path, self, true)
	

func _on_spawn_timer_timeout() -> void:
	if assembly_running == false:
		return
	var node = MECHA_KOOPA_ASSEMBLY_PART.instantiate()
	node.global_position = spawn_location.global_position
	add_child(node)

func _process(delta: float) -> void:
	for i in conveyor_sprites:
		if is_instance_valid(i) == false:
			return
		if broken:
			i.speed_scale = 5
		if assembly_running:
			i.play()
		elif not broken:
			i.stop()
	conveyor.constant_linear_velocity.x = (-64 if assembly_running else 0)

func conveyor_collapse() -> void:
	SoundManager.play_sfx(SoundManager.shatter, conveyor)
	for i in conveyor_sprites:
		ParticleManager.summon_four_part([BLOCK_BREAK, null, BLOCK_BREAK, null], i.global_position, 8)
		i.queue_free()

func assemble_piece() -> void:
	if broken:
		return
	$AssemblyTimer.stop()
	assembly_running = false
	await get_tree().create_timer(2, false).timeout
	assembly_running = true
	$AssemblyTimer.start()
