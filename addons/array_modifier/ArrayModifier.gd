extends Spatial
tool

export (Array, int) var repeat_levels = [1] setget set_repeat_levels
export (Array, Vector3) var repeat_offsets = [Vector3(1, 0, 0)] setget set_repeat_offsets
export (bool) var force_refresh = false setget set_force_refresh

var _hooks = Dictionary()


func _ready():
	_adjust_copies()


func apply_array_modifier():
	var parent = get_parent()
	
	# Move copies
	for hook in _hooks.values():
		for child in hook.get_children():
			hook.remove_child(child)
			parent.add_child_below_node(self, child)
			child.owner = self.owner
		remove_child(hook)
		hook.queue_free()
	
	# Move actual children (not hooks/copies)
	for child in get_children():
		remove_child(child)
		parent.add_child_below_node(self, child)
		child.owner = self.owner
	
	queue_free()


func set_repeat_levels(value):
	# Make sure the value will be at least 1
	for i in range(len(value)):
		value[i] = max(value[i], 1)
	
	repeat_levels = value
	
	while len(repeat_levels) > len(repeat_offsets):
		repeat_offsets.append(Vector3(1, 0, 0))
	
	while len(repeat_levels) < len(repeat_offsets):
		repeat_offsets.pop_back()
	
	_adjust_copies()


func set_repeat_offsets(value):
	# Make sure there is always the same number of offsets and levels
	if len(value) != len(repeat_offsets):
		return
	
	repeat_offsets = value
	
	_adjust_position_of_copies()


func set_force_refresh(value):
	_adjust_copies()


func _adjust_copies():
	# Clean up existing hooks
	for child in get_children():
		if child.name.begins_with(_get_hook_name_prefix()):
			remove_child(child)
			child.queue_free()
	
	var total_copy_count = 1
	for level in range(len(repeat_levels)):
		total_copy_count *= repeat_levels[level]
	
	for orig_child in get_children():
		# Ignore hooks
		if orig_child.name.begins_with(_get_hook_name_prefix()):
			continue
		
		# Create a "hook" for each actual child, to hold the copies in
		var hook = Spatial.new()
		hook.name = _get_hook_name(orig_child)
		add_child(hook)
		_hooks[hook.name] = hook
		
		# Index 0 would be the original, so start with 1
		for index in range(1, total_copy_count):
			var temp_index = index
			var local_offset = Vector3()
			for i in range(len(repeat_levels)):
				var repeat_level = repeat_levels[i]
				var repeat_offset = repeat_offsets[i]
				var coordinate = temp_index % repeat_level
				temp_index = int(temp_index / repeat_level)
				local_offset += repeat_offset * coordinate
			var copy = orig_child.duplicate()
			copy.translate(local_offset)
			hook.add_child(copy)


func _adjust_position_of_copies():
	var total_copy_count = 1
	for level in range(len(repeat_levels)):
		total_copy_count *= repeat_levels[level]
	
	for orig_child in get_children():
		# Ignore hooks
		if orig_child.name.begins_with(_get_hook_name_prefix()):
			continue
		
		# Find the corresponding hook
		var hook = _hooks.get(_get_hook_name(orig_child))
		if hook == null:
			printerr("Corresponding hook not found: ", orig_child.name)
			return
		
		# Index 0 would be the original, so start with 1
		for index in range(1, total_copy_count):
			var temp_index = index
			var local_offset = Vector3()
			for i in range(len(repeat_levels)):
				var repeat_level = repeat_levels[i]
				var repeat_offset = repeat_offsets[i]
				var coordinate = temp_index % repeat_level
				temp_index = int(temp_index / repeat_level)
				local_offset += repeat_offset * coordinate
			# Find the copy that should be moved
			var copy = hook.get_children()[index - 1]
			copy.translation = orig_child.translation + local_offset


func _get_hook_name_prefix():
	return "_array_modifier_hook_" + str(get_instance_id())


func _get_hook_name(child):
	return _get_hook_name_prefix() + "_" + str(child.get_instance_id())
