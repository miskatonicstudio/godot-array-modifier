tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"ArrayModifier",
		"Spatial",
		preload("ArrayModifier.gd"),
		preload("array_modifier_icon.png")
	)


func _exit_tree():
	remove_custom_type("ArrayModifier")
