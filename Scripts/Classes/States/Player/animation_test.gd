extends PlayerState

var animation_index := 0
const BIG = preload("res://Resources/PlayerSpriteFrames/Mario/Big.tres")
const power_states := [
	"Small",
	"Big",
	"Fire",
	"Ice",
	"Shell",
	"Propeller"
]

const characters := [
	"Mario",
	"Luigi",
	"LuigiSMAS",
	"LuigiSMA2",
	"Toad",
	"Toadette"
]

func enter(_msg := {}) -> void:
	test()

func physics_update(delta: float) -> void:
	player.velocity = Vector2.ZERO
	player.sprite_speed_scale = 1
	player.sprite.speed_scale = 1

func test() -> void:
	for i in characters:
		var big_test: SpriteFrames = load("res://Resources/PlayerSpriteFrames/Mario/Small.tres")
		for power_state in power_states:
			var check_frames: SpriteFrames = load("res://Resources/PlayerSpriteFrames/" + i + "/" + power_state + ".tres")
			if check_frames != null:
				for a in big_test.get_animation_names():
					if check_frames.has_animation(a):
						if check_frames.get_frame_count(a) == 0:
							push_error(i + " - " + power_state + ": " + a + " is empty!")
					else:
						check_frames.add_animation(a)
					check_frames.set_animation_speed(a, big_test.get_animation_speed(a))
					check_frames.set_animation_loop(a, big_test.get_animation_loop(a))
				ResourceSaver.save(check_frames, check_frames.resource_path)
			else:
				push_error(i + " - " + power_state + " does not have any animation frames!!!")
				
