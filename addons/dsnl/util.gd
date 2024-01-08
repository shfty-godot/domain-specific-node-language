class_name DSNLUtil

static func create_resource_tree_node(tree: Dictionary, override: bool = false) -> Node:
	var _script_resource_node := load("res://addons/dsnl/scripts/resource_node.gd")
	var _script_resource_tree_node := load("res://addons/dsnl/scripts/resource_tree_node.gd")

	var node = ClassDB.instance(tree.node_data.base_type)

	if tree.packed and not override:
		node.set_script(_script_resource_tree_node)
		node.set_resource_tree(tree)
	else:
		var properties = tree.node_data.properties.keys()
		properties.erase("script")
		properties.erase("resource")
		for property in ["script", "resource"] + properties:
			node.set(property, tree.node_data.properties[property])
			print(property, ': ', tree.node_data.properties[property])
		for child in tree.children:
			node.add_child(create_resource_tree_node(child))

	node.set_name(tree.node_data.name)

	return node

static func find_parent_by_script(node: Node, script: Script) -> Node:
	var candidate = node

	while true:
		if script_inherits(candidate.get_script(), script):
			return candidate

		candidate = candidate.get_parent()
		if not candidate:
			break

	return null

static func script_inherits(script: Script, base_script: Script) -> bool:
	if not script:
		return false

	if script == base_script:
		return true

	var base = script.get_base_script()
	if base == base_script:
		return true

	return false
