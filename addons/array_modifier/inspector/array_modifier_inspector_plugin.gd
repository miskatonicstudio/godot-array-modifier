extends EditorInspectorPlugin


func _can_handle(object):
	return object.has_method("apply_array_modifier") or object.has_method("refresh_duplicates")


func _parse_begin(object):
	if object.has_method("apply_array_modifier"):
		var button = Button.new()
		button.text = "Apply"
		button.tooltip_text = "Apply array modifier"
		button.connect("pressed", object.apply_array_modifier)
		add_custom_control(button)
	
	if object.has_method("refresh_duplicates"):
		var button = Button.new()
		button.text = "Refresh"
		button.tooltip_text = "Refresh duplicated objects"
		button.connect("pressed", object.refresh_duplicates)
		add_custom_control(button)
