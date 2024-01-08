class_name DSNLEditorPlugin
extends EditorPlugin
tool

# Constants
const SCRIPT_DSL_NODE := preload("res://addons/dsnl/scripts/dsl_node.gd")
const SCRIPT_RESOURCE_NODE := preload("res://addons/dsnl/scripts/resource_node.gd")
const SCRIPT_RESOURCE_TREE_NODE := preload("res://addons/dsnl/scripts/resource_tree_node.gd")

const HANDLED_TYPES := [
	SCRIPT_DSL_NODE,
	SCRIPT_RESOURCE_NODE,
	SCRIPT_RESOURCE_TREE_NODE
]

# Private Members
var _inspector_button: CollapseExpandButton
var _edited_object: Object

# Overrides
func _init() -> void:
	_inspector_button = CollapseExpandButton.new()
	_inspector_button.icon = get_editor_icon("Node")
	_inspector_button.connect("set_editor_selection", self, "set_editor_selection")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_inspector_button.free()

func _enter_tree() -> void:
	add_custom_type("DSLNode", "Node", SCRIPT_DSL_NODE, get_editor_icon("ButtonGroup"))
	add_custom_type("ResourceNode", "Node", SCRIPT_RESOURCE_NODE, get_editor_icon("Object"))
	add_custom_type("ResourceTreeNode", "Node", SCRIPT_RESOURCE_TREE_NODE, get_editor_icon("ResourcePreloader"))

func _exit_tree() -> void:
	remove_custom_type("DSLNode")
	remove_custom_type("ResourceNode")
	remove_custom_type("ResourceTreeNode")

func get_handled_types() -> Array:
	return [
		SCRIPT_DSL_NODE,
		SCRIPT_RESOURCE_NODE,
		SCRIPT_RESOURCE_TREE_NODE
	]

func handles(object: Object) -> bool:
	var handled := false
	for type in get_handled_types():
		if object is type:
			handled = true
	return handled

func make_visible(visible: bool) -> void:
	if visible:
		if not _inspector_button.get_parent():
			_inspector_button.set_target_node(_edited_object)
			add_control_to_container(CONTAINER_PROPERTY_EDITOR_BOTTOM, _inspector_button)
	else:
		if _inspector_button.get_parent():
			_inspector_button.set_target_node(null)
			remove_control_from_container(CONTAINER_PROPERTY_EDITOR_BOTTOM, _inspector_button)

func edit(object: Object) -> void:
	_edited_object = object
	edited_object_changed()

# Change Handlers
func edited_object_changed() -> void:
	update_inspector_button()

# Business Logic
func get_editor_icon(icon: String) -> Texture:
	return get_editor_interface().get_base_control().get_icon(icon, "EditorIcons")

func set_editor_selection(node: Node) -> void:
	var selection = get_editor_interface().get_selection()
	selection.clear()
	selection.add_node(node)

func update_inspector_button() -> void:
	if DSNLUtil.script_inherits(_edited_object.get_script(), SCRIPT_RESOURCE_NODE):
		_inspector_button.icon = get_editor_icon("ResourcePreloader")
	elif DSNLUtil.script_inherits(_edited_object.get_script(), SCRIPT_RESOURCE_TREE_NODE):
		_inspector_button.icon = get_editor_icon("Object")
	elif DSNLUtil.script_inherits(_edited_object.get_script(), SCRIPT_DSL_NODE):
		_inspector_button.icon = get_editor_icon("ButtonGroup")

	_inspector_button.disabled = _edited_object == get_tree().get_edited_scene_root()
