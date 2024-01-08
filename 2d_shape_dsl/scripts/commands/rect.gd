class_name CommandRect
extends Resource
tool

export(Vector2) var position := Vector2.ZERO
export(Vector2) var size := Vector2(10, 10)
export(Color) var color := Color.white

func _init() -> void:
	if get_name().empty():
		set_name("Rect")
