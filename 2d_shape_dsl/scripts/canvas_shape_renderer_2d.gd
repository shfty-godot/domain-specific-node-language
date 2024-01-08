class_name CanvasShapeRenderer2D
extends CanvasItem
tool

export(Resource) var draw_commands: Resource setget set_draw_commands

var _position := Vector2.ZERO

func set_draw_commands(new_draw_commands: Resource) -> void:
	if draw_commands != new_draw_commands:
		if draw_commands and draw_commands.is_connected("changed", self, "changed"):
			draw_commands.disconnect("changed", self, "update")

		draw_commands = new_draw_commands

		if draw_commands and not draw_commands.is_connected("changed", self, "update"):
			draw_commands.connect("changed", self, "update")

		update()

func _draw() -> void:
	for command in draw_commands.data:
		if command is CommandPushTransform:
			_position += command.position
		elif command is CommandPopTransform:
			_position -= command.position
		elif command is CommandCircle:
			draw_circle(_position, command.radius, command.color)
		elif command is CommandRect:
			draw_rect(Rect2(_position, command.size), command.color, true)
