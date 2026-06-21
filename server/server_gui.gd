class_name ServerGUI
extends CanvasLayer

@onready var level_controller: Control = %LevelController
@onready var player_list: Control = %PlayerList
@onready var countdownlabel = %CountdownDisplay
@onready var countdown_sequence_input = %CountdownSequenceInput
@onready var watch_path = %WatchPath
@onready var dir_watcher: DirectoryWatcher = $DirectoryWatcher

var player_list_items: Dictionary[int, PlayerInfoDisplay] = {}

func _ready() -> void:
	SignalBus.on_countdown.connect(_on_countdown)
	SignalBus.on_change_scene.connect(_on_change_scene)
	SignalBus.on_any_win.connect(_on_any_won)
	level_controller.visible = false

func _on_watch_path_text_submitted(new_text: String) -> void:
	dir_watcher.remove_scan_directory(watch_path.text)
	dir_watcher.add_scan_directory(new_text)
	if not new_text.is_empty():
		SettingsManager.save_setting("Server", "watch_path", new_text)

func _on_file_list_on_press_send(fp: String) -> void:
	SignalBus.s_file_press_send(fp)

func _on_change_scene(_node):
	level_controller.visible = true

func add_player(pid: int, info: PlayerInfo):
	var display: PlayerInfoDisplay = preload("res://server/PlayerInfoDisplay.tscn").instantiate()
	display.set_info(info)
	display.name = str(pid)
	player_list.add_child(display)
	player_list_items[pid] = display
	
# ============================================================================
# rankings
# ============================================================================

func _on_any_won(pid: int, place: String):
	player_list_items[pid].set_place(place)

func clear_places():
	for child in player_list_items.values():
		child.hide_place()


# ============================================================================
# camera
# ============================================================================


func _on_prev_camera_button_pressed() -> void:
	SignalBus.cam_switch(1, false)


func _on_next_camera_button_pressed() -> void:
	SignalBus.cam_switch(1, true)


# ============================================================================
# countdown
# ============================================================================

func _on_start_countdown_button_pressed() -> void:
	var tree = get_tree()
	var input: String = countdown_sequence_input.text
	var parts = Array(input.split(",")) \
		.map(func(x): return x.strip_edges()) \
		.filter(func(x): return not x.is_empty())
	for i in range(parts.size()):
		var part = parts[i]
		var is_last = i == parts.size() - 1
		SignalBus.countdown.rpc(part, 1.0 if is_last else 3.0, is_last)
		await tree.create_timer(1.0).timeout


var countdown_tween: Tween
func _on_countdown(display: String, length: float, _final: bool):
	countdownlabel.text = display
	if countdown_tween:
		countdown_tween.kill()
	countdown_tween = create_tween()
	countdown_tween.tween_interval(length)
	countdown_tween.tween_callback(_on_countdown_finish)

func _on_countdown_finish():
	countdownlabel.text = ""


func _on_unlock_players_button_pressed() -> void:
	SignalBus.countdown.rpc("go!", 1.0, true)
