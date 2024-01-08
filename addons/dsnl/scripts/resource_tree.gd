class_name ResourceTree
extends Resource
tool

export(Dictionary) var data

func _init() -> void:
	if get_name().empty():
		set_name("Resource Tree")
