class_name DrawCommands
extends Resource
tool

export(Array, Resource) var data := []

func _init() -> void:
	if get_name().empty():
		set_name("DrawCommands")
