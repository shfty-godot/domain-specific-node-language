class_name CollapseExpandButton
extends Button
tool

signal set_editor_selection(node)

# Private Members
var _target_node: Node setget set_target_node, get_target_node

# Setters
func set_target_node(new_target_node: Node) -> void:
	if _target_node != new_target_node:
		_target_node = new_target_node
		_target_node_changed()

# Getters
func get_target_node() -> Node:
	return _target_node

# Change Handlers
func _target_node_changed() -> void:
	if _target_node:
		if _target_node.has_method("get_toggle_button_text"):
			text = _target_node.get_toggle_button_text()
	else:
		text = "Toggle"

# Overrides
func _init() -> void:
	_target_node_changed()

	connect("pressed", self, "pressed")

func pressed() -> void:
	if _target_node:
		if _target_node.has_method("toggle"):
			var resource_tree_node = _target_node.toggle()
			emit_signal("set_editor_selection", resource_tree_node)
