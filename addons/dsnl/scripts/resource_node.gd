extends Node
tool

# Constants
const CATEGORY_BLACKLIST := [
	"Resource"
]

const PROPERTY_BLACKLIST := [
	"editor_description",
	"process_priority",
	"pause_mode",
	"script"
]

# Public Members
export(Resource) var resource: Resource setget set_resource, get_resource

# Setters
func set_resource(new_resource: Resource) -> void:
	if resource != new_resource:
		resource = new_resource
		_resource_changed()
		property_list_changed_notify()

# Getters
func get_resource() -> Resource:
	return resource

func get_toggle_button_text() -> String:
	return "Collapse"

# Change Handlers
func _resource_changed() -> void:
	if is_inside_tree():
		update_parent_dsl()

# Overrides
func _init() -> void:
	if not is_connected("renamed", self, "renamed"):
		connect("renamed", self, "renamed")

func _enter_tree() -> void:
	if resource:
		resource = resource.duplicate()

	update_parent_dsl()

func _get(property: String):
	if property == "editor_description":
		return editor_description

	if property == "process_priority":
		return process_priority

	if property == "pause_mode":
		return pause_mode

	if property == "script":
		return get_script()

	if resource:
		return resource.get(property)

	return null

func _set(property: String, value) -> bool:
	if property == "editor_description":
		editor_description = value
		update_parent_dsl()
		return true

	if property == "process_priority":
		process_priority = value
		update_parent_dsl()
		return true

	if property == "pause_mode":
		pause_mode = value
		update_parent_dsl()
		return true

	if property == "script":
		set_script(value)
		return true

	if resource:
		if property in resource:
			resource.set(property, value)
			update_parent_dsl()
			return true

	update_parent_dsl()
	return false

func _get_property_list() -> Array:
	var property_list := []

	if resource:
		var resource_properties = resource.get_property_list()
		var skip_category := false
		for property in resource_properties:
			if PROPERTY_USAGE_CATEGORY & property.usage:
				if property.name in CATEGORY_BLACKLIST:
					skip_category = true
				else:
					skip_category = false

			if skip_category or property.name in PROPERTY_BLACKLIST:
				continue

			property.usage &= ~PROPERTY_USAGE_STORAGE
			property_list.append(property)

	return property_list

func _get_configuration_warning() -> String:
	if self == get_tree().get_edited_scene_root():
		return "ResourceNodes as the scene root cannot be collapsed."

	return ""

# Business Logic
func renamed() -> void:
	update_parent_dsl()

func get_resource_tree() -> Dictionary:
	var properties := {}

	for property in get_property_list():
		var is_category = PROPERTY_USAGE_CATEGORY & property.usage
		if is_category:
			continue

		var is_group = PROPERTY_USAGE_GROUP & property.usage
		if is_group:
			continue

		var is_storage = PROPERTY_USAGE_STORAGE & property.usage
		if not is_storage:
			continue

		properties[property.name] = get(property.name)

	var resource_tree := {
		"node_data": {
			"name": get_name(),
			"base_type": get_script().get_instance_base_type(),
			"properties": properties
		},
		"children": [],
		"packed": false
	}

	for child in get_children():
		if child.has_method("get_resource_tree"):
			resource_tree.children.append(child.get_resource_tree())

	return resource_tree

func toggle() -> Node:
	var resource_tree = get_resource_tree()

	var script_resource_tree_node := load("res://addons/dsnl/scripts/resource_tree_node.gd")
	var resource_tree_node = script_resource_tree_node.new()
	resource_tree_node.set_resource_tree(resource_tree)

	for child in get_children():
		if child.get_script() == get_script() or child.get_script() == script_resource_tree_node:
			remove_child(child)
			child.queue_free()

	var owner = get_owner()
	replace_by(resource_tree_node)
	resource_tree_node.set_owner(owner)

	return resource_tree_node

func update_parent_dsl() -> void:
	var script_dsl_node := load("res://addons/dsnl/scripts/dsl_node.gd")
	var parent_dsl = DSNLUtil.find_parent_by_script(self, script_dsl_node)
	if parent_dsl:
		parent_dsl.update_data()
	request_ready()
