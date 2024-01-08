extends ColorRect
tool

const SHADER_TEMPLATE = """
shader_type canvas_item;

float dist_circle(vec2 uv, vec2 position, float radius) {
	float half_frag = length(fwidth(uv)) * 0.5;
	return smoothstep(-half_frag, half_frag, length(uv - position) - radius);
}

float dist_rect(vec2 uv, vec2 position, vec2 size) {
	float half_frag = length(fwidth(uv)) * 0.5;
	vec2 delta = abs((position + size * 0.5) - uv) - (size * 0.5);
	float dist = length(max(delta, 0.0)) + min(max(delta.x, delta.y), 0.0);
	return smoothstep(-half_frag, half_frag, dist);
}

void vertex() {
	UV = VERTEX;
}

void fragment() {
	vec3 color = vec3(1.0);
	float dist = 1.0;
	float new_dist = 1.0;
	%s
	COLOR = vec4(color, 1.0 - dist);
}
"""

const CIRCLE_TEMPLATE := """
	new_dist = dist_circle(UV, vec2(%s, %s), %s);
	if(new_dist <= dist) {
		dist = new_dist;
		color = vec3(%s, %s, %s);
	}
"""

const RECT_TEMPLATE := """
	new_dist = dist_rect(UV, vec2(%s, %s), vec2(%s, %s));
	if(new_dist <= dist) {
		dist = new_dist;
		color = vec3(%s, %s, %s);
	}
"""

export(Resource) var draw_commands: Resource setget set_draw_commands

var _position := Vector2.ZERO

func _init() -> void:
	material = ShaderMaterial.new()
	material.shader = Shader.new()

func set_draw_commands(new_draw_commands: Resource) -> void:
	if draw_commands != new_draw_commands:
		if draw_commands and draw_commands.is_connected("changed", self, "update_shader"):
			draw_commands.disconnect("changed", self, "update_shader")

		draw_commands = new_draw_commands

		if draw_commands and not draw_commands.is_connected("changed", self, "update_shader"):
			draw_commands.connect("changed", self, "update_shader")

		update_shader()

func update_shader() -> void:
	var shape_snippets := PoolStringArray([])

	for command in draw_commands.data:
		if command is CommandPushTransform:
			_position += command.position
		elif command is CommandPopTransform:
			_position -= command.position
		elif command is CommandCircle:
			shape_snippets.append(add_circle(_position, command.radius, command.color))
		elif command is CommandRect:
			shape_snippets.append(add_rect(Rect2(_position, command.size), command.color))

	material.shader.code = SHADER_TEMPLATE % [shape_snippets.join("")]

func add_circle(position: Vector2, radius: float, color: Color) -> String:
	return CIRCLE_TEMPLATE % [position.x, position.y, radius, color.r, color.g, color.b]

func add_rect(rect: Rect2, color: Color) -> String:
	return RECT_TEMPLATE % [rect.position.x, rect.position.y, rect.size.x, rect.size.y, color.r, color.g, color.b]
