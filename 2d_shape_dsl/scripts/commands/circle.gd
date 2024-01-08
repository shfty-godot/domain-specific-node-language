class_name CommandCircle
extends Resource
tool

export(Vector2) var position := Vector2.ZERO
export(float) var radius := 10.0
export(Color) var color := Color.white

func _init() -> void:
	if get_name().empty():
		set_name("Circle")
