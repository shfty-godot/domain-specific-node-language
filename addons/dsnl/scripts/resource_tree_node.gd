extends Node
tool

# Public Members
export(Dictionary) var resource_tree: Dictionary setget set_resource_tree, get_resource_tree

# Private Members
onready var _script_dsl_node := load("res://addons/dsnl/scripts/dsl_node.gd")
onready var _script_resource_node := load("res://addons/dsnl/scripts/resource_node.gd")

# Setters
func set_resource_tree(new_resource_tree: Dictionary) -> void:
	if resource_tree != new_resource_tree:
		resource_tree = new_resource_tree
		resource_tree.packed = true

		set_name(resource_tree.node_data.name)

# Getters
func get_resource_tree() -> Dictionary:
	return resource_tree

func get_toggle_button_text() -> String:
	return "Expand"

# Overrides
func _ready() -> void:
	var parent_dsl = DSNLUtil.find_parent_by_script(self, _script_dsl_node)
	if parent_dsl:
		parent_dsl.update_data()
	request_ready()

func _get_configuration_warning() -> String:
	if self == get_tree().get_edited_scene_root():
		return "ResourceTreeNodes at the scene root cannot be expanded."

	for child in get_children():
		if child.get_script() == _script_resource_node or child.get_script() == get_script():
			return "Adding ResourceNode or ResourceTreeNode a child of ResourceTreeNode is undefined behavior."

	return ""

# Business Logic
func toggle() -> Node:
	var node = DSNLUtil.create_resource_tree_node(resource_tree, true)
	var owner = get_owner()
	replace_by(node)
	node.propagate_call("set_owner", [owner])
	return node
