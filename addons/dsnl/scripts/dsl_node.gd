extends Node
tool

export(Array, Resource) var resource_trees := []

var _locked := false

# Getters
func get_target_nodes() -> Array:
	var target_nodes := []
	for child in get_children():
		var script_resource_node = load("res://addons/dsnl/scripts/resource_node.gd")
		var script_resource_tree_node = load("res://addons/dsnl/scripts/resource_tree_node.gd")
		if DSNLUtil.script_inherits(child.get_script(), script_resource_node) or DSNLUtil.script_inherits(child.get_script(), script_resource_tree_node):
			target_nodes.append(child)
	return target_nodes

func get_toggle_button_text() -> String:
	return "Collapse" if get_target_nodes().size() > 0 else "Expand"

# Change Handlers
func update_data() -> void:
	if _locked:
		return

	var target_nodes = get_target_nodes()
	if target_nodes.size() == 0:
		return

	resource_trees.clear()
	for node in target_nodes:
		resource_trees.append(node.get_resource_tree())

	data_changed()

func data_changed() -> void:
	clear()
	for resource_tree in resource_trees:
		interpret_resource_tree(resource_tree)
	finalize()
	property_list_changed_notify()

func interpret_resource_tree(tree: Dictionary) -> void:
	pre_interpret_resource(tree.node_data.properties.resource)

	for child in tree.children:
		interpret_resource_tree(child)

	post_interpret_resource(tree.node_data.properties.resource)

func clear() -> void:
	pass

func pre_interpret_resource(resource: Resource) -> void:
	pass

func post_interpret_resource(resource: Resource) -> void:
	pass

func finalize() -> void:
	pass

# Overrides
func _ready() -> void:
	update_data()

# Business Logic
func toggle() -> Node:
	var target_nodes = get_target_nodes()
	if target_nodes.size() > 0:
		for node in target_nodes:
			remove_child(node)
			node.queue_free()
	else:
		_locked = true
		for resource_tree in resource_trees:
			var node = DSNLUtil.create_resource_tree_node(resource_tree)
			add_child(node)
			node.propagate_call("set_owner", [get_tree().get_edited_scene_root()])
		_locked = false

	return self
