extends EditorInspectorPlugin


func can_handle(object):
	return object.has_method("apply_array_modifier")


func parse_begin(object):
	if object.has_method("apply_array_modifier"):
		var button = Button.new()
		button.text = "Apply"
		button.hint_tooltip = "Apply array modifier"
		button.align  = Button.ALIGN_CENTER
		button.size_flags_horizontal = Button.SIZE_EXPAND_FILL
		button.connect("pressed", object, "apply_array_modifier")
		add_custom_control(button)
