extends Label

static var title_index := 0

var colours := [Color("f8d870"), Color("f85858"), Color("58f858")]

func _ready() -> void:
	title_index += 1
	title_index = wrap(title_index, 0, 3)
	modulate = colours[title_index]
