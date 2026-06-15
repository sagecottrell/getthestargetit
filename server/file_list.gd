extends VBoxContainer

signal on_press_send(fp: String)

func _on_directory_watcher_files_modified(files: PackedStringArray) -> void:
	prints("modified", files)
	for file_path in files:
		var n = str(hash(file_path))
		var child = find_child(n, false, false)
		if child is FileSelector:
			child.update()
		else:
			_create_fileselector(file_path)

func _on_directory_watcher_files_deleted(files: PackedStringArray) -> void:
	prints("deleted", files)
	for file_path in files:
		var n = str(hash(file_path))
		var child = find_child(n, false, false)
		if child is FileSelector:
			child.queue_free()


func _on_directory_watcher_files_created(files: PackedStringArray) -> void:
	prints("created", files)
	for file_path in files:\
		_create_fileselector(file_path)

func _create_fileselector(fp: String):
	var child: FileSelector = preload("res://server/FileSelector.tscn").instantiate()
	child.name = str(hash(fp))
	child.file_path = fp
	add_child(child)
	child.pressed.connect(on_press_send.emit)
	
