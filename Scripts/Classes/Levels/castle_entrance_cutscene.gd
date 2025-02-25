extends CutsceneLevel

@onready var player_animations := [$P1/Sprite/Animation, $P2/Sprite/Animation, $P3/Sprite/Animation, $P4/Sprite/Animation]

@onready var player_sprites := [$P1/Sprite, $P2/Sprite, $P3/Sprite, $P4/Sprite]

var yoshi_present := false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		cutscene_finish()

func spawn() -> void:
	for i in 4:
		if CoopManager.player_yoshis[i] == true:
			yoshi_present = true
		if CoopManager.players_connected >= i:
			break
		
	for i in player_sprites:
		i.hide()
	for i in CoopManager.players_connected:
		player_sprites[i].show()
	if yoshi_present:
		spin_yoshi_jump()
		$Door/AnimationPlayer.play("Wait")
	else:
		$Door/AnimationPlayer.play("Normal")
	for i in 4:
		if i >= CoopManager.players_connected:
			return
		player_sprites[i].get_node("Yoshi").colour = CoopManager.yoshi_colours[i]
		player_sprites[i].set_to_player_info(i)
		if CoopManager.player_yoshis[i] == true:
			player_animations[i].play("Yoshi")
		elif yoshi_present:
			player_animations[i].play("NoYoshiWait")
		else:
			player_animations[i].play("NoYoshi")

func spin_yoshi_jump() -> void:
	await get_tree().create_timer(3, false).timeout
	SoundManager.play_global_sfx(SoundManager.spin)

func end() -> void:
	SoundManager.play_global_sfx(SoundManager.bullet)
	cutscene_finish()
