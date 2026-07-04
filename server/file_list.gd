extends VBoxContainer

@onready var watch_path = %WatchPath
@onready var dir_watcher: DirectoryWatcher = $DirectoryWatcher

func _ready():
	dir_watcher.files_created.connect(_on_directory_watcher_files_created)
	dir_watcher.files_deleted.connect(_on_directory_watcher_files_deleted)
	dir_watcher.files_modified.connect(_on_directory_watcher_files_modified)
	
	var saved_watch_dir: String = SettingsManager.load_setting("Server", "watch_path", "")
	if not saved_watch_dir.is_empty():
		dir_watcher.add_scan_directory(saved_watch_dir)
		watch_path.text = saved_watch_dir

func _on_watch_path_text_submitted(new_text: String) -> void:
	dir_watcher.remove_scan_directory(watch_path.text)
	dir_watcher.add_scan_directory(new_text)
	if not new_text.is_empty():
		SettingsManager.save_setting("Server", "watch_path", new_text)

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
	for file_path in files:
		_create_fileselector(file_path)

func _create_fileselector(fp: String):
	var child: FileSelector = preload("res://server/FileSelector.tscn").instantiate()
	child.name = str(hash(fp))
	child.file_path = fp
	add_child(child)
	child.pressed.connect(SignalBus.s_file_press_send)
