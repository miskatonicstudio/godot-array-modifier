@tool
extends Node

var _undo_redo : EditorUndoRedoManager


func apply_array_modifier(array_node: Node):
	var parent = array_node.get_parent()
	
	_undo_redo.create_action("Apply Array Modifier")
	
	for hook in array_node._hooks.values():
		for child in hook.get_children():
			_undo_redo.add_do_method(hook, "remove_child", child)
			_undo_redo.add_do_method(array_node, "add_child", child)
			_undo_redo.add_do_method(child, "set_owner", array_node.owner)
			_undo_redo.add_undo_method(array_node, "remove_child", child)
			_undo_redo.add_undo_method(child, "queue_free")
	_undo_redo.add_undo_method(array_node, "refresh_duplicates")
	_undo_redo.commit_action()
