tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"ArrayModifier",
		"Spatial",
		preload("ArrayModifier.gd"),
		preload("array_modifier_icon.png")
	)
	add_custom_type(
		"ArrayModifierPath",
		"Spatial",
		preload("ArrayModifierPath.gd"),
		preload("array_modifier_path_icon.png")
	)
	add_custom_type(
		"ArrayModifier2D",
		"Node2D",
		preload("ArrayModifier2D.gd"),
		preload("array_modifier_2d_icon.png")
	)
	add_custom_type(
		"ArrayModifierPath2D",
		"Node2D",
		preload("ArrayModifierPath2D.gd"),
		preload("array_modifier_path_2d_icon.png")
	)


func _exit_tree():
	remove_custom_type("ArrayModifier")
	remove_custom_type("ArrayModifierPath")
	remove_custom_type("ArrayModifier2D")
	remove_custom_type("ArrayModifierPath2D")
