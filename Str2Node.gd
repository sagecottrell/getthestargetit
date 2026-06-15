class_name Str2Node


static func tscn_string_to_node(tscn_text: String) -> Node:
	var temp_path = "user://temp_runtime_scene.tscn"
	
	# 1. Save the string content into a temporary file
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	if file:
		file.store_string(tscn_text)
		file.close()
	else:
		push_error("Failed to write temporary TSCN text file.")
		return null
		
	# 2. Load the file path into a PackedScene resource
	var packed_scene = ResourceLoader.load(temp_path) as PackedScene
	
	# 3. Safely delete the temporary file from disk
	DirAccess.remove_absolute(temp_path)
	
	# 4. Return the instantiated node tree
	if packed_scene:
		return packed_scene.instantiate()
	else:
		push_error("Failed to parse and load the TSCN text string.")
		return null
