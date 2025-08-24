@tool
extends Node2D

@export var path: Path2D : set = set_path
@export_range(0, 1, 0.001) var path_offset_start: float : set = set_path_offset_start
@export var repeat_offset: float : set = set_repeat_offset
@export var instance_offset: Vector2 = Vector2.ZERO

@export var repeat_count: int = 1 : set = set_repeat_count

var _hooks = Dictionary()


func _ready():
	refresh_duplicates()


func _get_copy_position_rotation(instance_number):
	var path_length = path.curve.get_baked_length()
	var position = path_offset_start + instance_number * repeat_offset 
	var absolute_offset = fmod(path_length * position, path_length)
	var offset_1 = max(absolute_offset - 0.01, 0)
	var offset_2 = min(absolute_offset + 0.01, path_length)
	var p1 = path.curve.sample_baked(offset_1, true)
	var p2 = path.curve.sample_baked(offset_2, true)
	var newpos = p1 + ((p2 - p1) / 2.0)

	return [newpos, p2]


func apply_array_modifier():
	Engine.get_singleton("undo_redo").apply_array_modifier.call_deferred(self)


func set_path(value: Path2D):
	path = value
	refresh_duplicates()


func set_path_offset_start(value):
	path_offset_start = value
	_adjust_position_of_duplicates()


func set_repeat_count(value):
	# Make sure the value will be at least 1
	repeat_count = max(value, 1)
	refresh_duplicates()


func set_repeat_offset(value):
	# Make sure there is always the same number of offsets and levels
	if value == repeat_offset:
		return
	
	repeat_offset = value
	
	_adjust_position_of_duplicates()


func refresh_duplicates():
	if not path:
		return
	
	# Clean up existing hooks
	for child in get_children():
		if child.name.begins_with(_get_hook_name_prefix()):
			remove_child(child)
			child.queue_free()
	
	for orig_child in get_children():
		# Ignore hooks
		if orig_child.name.begins_with(_get_hook_name_prefix()):
			continue
		
		# Create a "hook" for each actual child, to hold the duplicates in
		var hook = Node2D.new()
		hook.name = _get_hook_name(orig_child)
		add_child(hook)
		_hooks[hook.name] = hook
		var duplicate_count = 1
		
		# Original instance has to be moved as well, so start with 0
		for index in range(0, repeat_count):
			var position_rotation = _get_copy_position_rotation(index)
			if index == 0:
				orig_child.transform.origin = position_rotation[0]
				orig_child.transform = Transform2D(
					position_rotation[1].angle_to_point(position_rotation[0]),
					position_rotation[0]
				)
				if instance_offset != Vector2.ZERO:
					orig_child.translate(
						get_transform() * instance_offset
					)
			else:
				var temp_index = index
				var copy = orig_child.duplicate()
				copy.name += "_dup" + str(duplicate_count)
				duplicate_count += 1
				copy.transform.origin = position_rotation[0] + instance_offset
				copy.transform = Transform2D(
					position_rotation[1].angle_to_point(position_rotation[0]),
					position_rotation[0]
				)
				if instance_offset != Vector2.ZERO:
					copy.translate(get_transform() * instance_offset)
				hook.add_child(copy)


func _adjust_position_of_duplicates():
	if not path:
		return
	
	for orig_child in get_children():
		# Ignore hooks
		if orig_child.name.begins_with(_get_hook_name_prefix()):
			continue
		
		# Find the corresponding hook
		var hook = _hooks.get(_get_hook_name(orig_child))
		if hook == null:
			printerr("Corresponding hook not found: ", orig_child.name)
			return
		
		# Original instance has to be moved as well, so start with 0
		for index in range(0, repeat_count):
			var position_rotation = _get_copy_position_rotation(index)
			if index == 0:
				orig_child.transform.origin = position_rotation[0]
				orig_child.transform = Transform2D(
					position_rotation[1].angle_to_point(position_rotation[0]),
					position_rotation[0]
				)
				if instance_offset != Vector2.ZERO:
					orig_child.translate(
						get_transform() * instance_offset
					)
			else:
				# Find the copy that should be moved
				var copy = hook.get_children()[index - 1]
				copy.transform.origin = position_rotation[0]
				copy.transform = Transform2D(
					position_rotation[1].angle_to_point(position_rotation[0]),
					position_rotation[0]
				)
				if instance_offset != Vector2.ZERO:
					copy.translate(get_transform() * instance_offset)


func _get_hook_name_prefix():
	return "_array_modifier_hook_" + str(get_instance_id())


func _get_hook_name(child):
	return _get_hook_name_prefix() + "_" + str(child.get_instance_id())
