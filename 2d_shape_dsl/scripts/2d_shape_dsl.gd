extends "res://addons/dsnl/scripts/dsl_node.gd"
tool

export(Resource) var draw_commands: Resource

# Overrides
func _enter_tree() -> void:
	if not draw_commands:
		draw_commands = DrawCommands.new()

func clear() -> void:
	draw_commands.data.clear()

func pre_interpret_resource(resource: Resource) -> void:
	if resource is CommandCircle:
		var push_transform = CommandPushTransform.new()
		push_transform.position = resource.position

		draw_commands.data.append(push_transform)
		draw_commands.data.append(resource)
	elif resource is CommandRect:
		var push_transform = CommandPushTransform.new()
		push_transform.position = resource.position

		draw_commands.data.append(push_transform)
		draw_commands.data.append(resource)

func post_interpret_resource(resource: Resource) -> void:
	if resource is CommandCircle:
		var pop_transform = CommandPopTransform.new()
		pop_transform.position = resource.position

		draw_commands.data.append(pop_transform)
	elif resource is CommandRect:
		var pop_transform = CommandPopTransform.new()
		pop_transform.position = resource.position

		draw_commands.data.append(pop_transform)

func finalize() -> void:
	draw_commands.emit_signal("changed")
