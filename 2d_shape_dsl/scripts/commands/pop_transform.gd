class_name CommandPopTransform
extends Resource
tool

export(Vector2) var position := Vector2.ZERO

func _init() -> void:
	if get_name().empty():
		set_name("PopTransform")
