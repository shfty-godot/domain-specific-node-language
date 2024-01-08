class_name MeshShapeRenderer2D
extends MeshInstance2D
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

		if is_inside_tree():
			update_array_mesh()

func _enter_tree() -> void:
	mesh = ArrayMesh.new()
	update_array_mesh()

func update_array_mesh() -> void:
	for i in range(0, mesh.get_surface_count()):
		mesh.surface_remove(0)

	for command in draw_commands.data:
		if command is CommandPushTransform:
			_position += command.position
		elif command is CommandPopTransform:
			_position -= command.position
		elif command is CommandCircle:
			add_circle(_position, command.radius, command.color)
		elif command is CommandRect:
			add_rect(Rect2(_position, command.size), command.color)

func add_circle(position: Vector2, radius: float, color: Color) -> void:
	var vertices := PoolVector3Array()
	var normals := PoolVector3Array()
	var colors := PoolColorArray()
	var uvs := PoolVector2Array()

	for i in range(0, 32):
		var rad = (float(i) / 32.0) * TAU
		var vertex = (Vector3.UP * radius).rotated(Vector3.FORWARD, rad)
		vertices.append(Vector3(position.x, position.y, 0.0) + vertex)
		normals.append(Vector3.FORWARD)
		colors.append(color)
		uvs.append(Vector2.UP.rotated(rad))

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_FAN, [
		vertices,
		normals,
		null,
		colors,
		uvs,
		null,
		null,
		null,
		null
	])

func add_rect(rect: Rect2, color: Color) -> void:
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_FAN, [
		PoolVector3Array([
			Vector3(rect.position.x, rect.position.y, 0.0),
			Vector3(rect.position.x, rect.position.y + rect.size.y, 0.0),
			Vector3(rect.position.x + rect.size.x, rect.position.y + rect.size.y, 0.0),
			Vector3(rect.position.x + rect.size.x, rect.position.y, 0.0),
			Vector3(rect.position.x, rect.position.y, 0.0),
		]),
		PoolVector3Array([
			Vector3.FORWARD,
			Vector3.FORWARD,
			Vector3.FORWARD,
			Vector3.FORWARD,
			Vector3.FORWARD,
		]),
		null,
		PoolColorArray([
			color,
			color,
			color,
			color,
			color
		]),
		PoolVector2Array([
			Vector2.ZERO,
			Vector2.RIGHT,
			Vector2.ONE,
			Vector2.UP,
			Vector2.ZERO
		]),
		null,
		null,
		null,
		null
	])
