class_name Server
extends Node

@onready var level_controller: Control = %LevelController
@onready var gui: Node = $ServerGUI
@onready var dir_watcher: DirectoryWatcher = $DirectoryWatcher
@onready var player_list: Control = %PlayerList

static var PlayerIds: Dictionary[int, PlayerInfo] = {}
static var PlayerList: Array[int] = []

static var rankings: Array[int] = []

func _ready() -> void:
	gui.visible = false
	level_controller.visible = false
	multiplayer.server_relay = true
	SignalBus.on_client_setup.connect(_on_client_setup)
	SignalBus.on_self_is_client.connect(_on_self_is_client)

func _on_multiplayer_on_host() -> void:
	# on the server side, when the server starts up
	gui.visible = true
	var saved_watch_dir: String = SettingsManager.load_setting("Server", "watch_path", "")
	if not saved_watch_dir.is_empty():
		dir_watcher.add_scan_directory(saved_watch_dir)
		%WatchPath.text = saved_watch_dir
	multiplayer.peer_connected.connect(_on_client_connect)
	multiplayer.peer_disconnected.connect(_on_client_disconnect)
	
	SignalBus.on_client_won.connect(_on_client_won)
	SignalBus.on_recieve_scene.connect(SignalBus.change_scene)
	SignalBus.on_countdown.connect(_on_countdown)

func _on_self_is_client():
	dir_watcher.queue_free()

func _on_client_connect(id: int):
	prints("client connected:", id)

func _on_client_disconnect(id: int):
	prints("client disconnected:", id)
	PlayerIds.erase(id)
	PlayerList.erase(id)
	rankings.erase(id)

func _on_client_setup(info: PlayerInfo):
	send_player_info.rpc_id(1, info.to_json())

@rpc("any_peer")
func send_player_info(json: String):
	# The server knows who sent the input.
	var sender_id = multiplayer.get_remote_sender_id()
	prints("setting up player", sender_id)
	var info: PlayerInfo = PlayerInfo.from_json(json)
	PlayerIds[sender_id] = info
	PlayerList.append(sender_id)
	
	var display: PlayerInfoDisplay = preload("res://server/PlayerInfoDisplay.tscn").instantiate()
	display.set_info(info)
	display.name = str(sender_id)
	player_list.add_child(display)

func _on_watch_path_text_submitted(new_text: String) -> void:
	dir_watcher.remove_scan_directory(%WatchPath.text)
	dir_watcher.add_scan_directory(new_text)
	if not new_text.is_empty():
		SettingsManager.save_setting("Server", "watch_path", new_text)

# ============================================================================
# setup level
# ============================================================================

@rpc("call_local")
func push_scene_to_all(txt: String):
	SignalBus.recieve_scene(Str2Node.tscn_string_to_node(txt))

func pack_and_send(fp: String):
	clear_places()
	
	var file = FileAccess.open(fp, FileAccess.READ)
	SignalBus.pre_level_push()
	
	await get_tree().create_timer(0.5).timeout
	
	push_scene_to_all.rpc(file.get_as_text())
	level_controller.visible = true

func _on_file_list_on_press_send(fp: String) -> void:
	pack_and_send(fp)

# ============================================================================
# player reach goal
# ============================================================================

func _on_client_won(pid: int):
	if pid in rankings:
		return
	var n = rankings.size() + 1
	rankings.append(pid)
	var child: PlayerInfoDisplay = player_list.find_child(str(pid), false, false)
	child.set_place(n)
	set_rank.rpc(pid, n)

@rpc("call_local")
func set_rank(sender_id: int, place: int):
	var n = {place: str(place) + "th", 1: "1st", 2: "2nd", 3: "3rd"}[place]
	SignalBus.any_win(sender_id, n)

func clear_places():
	rankings.clear()
	for child in player_list.get_children():
		if child is PlayerInfoDisplay:
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
	var input: String = %CountdownSequenceInput.text
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
	%CountdownDisplay.text = display
	if countdown_tween:
		countdown_tween.kill()
	countdown_tween = create_tween()
	countdown_tween.tween_interval(length)
	countdown_tween.tween_callback(_on_countdown_finish)

func _on_countdown_finish():
	%CountdownDisplay.text = ""


func _on_unlock_players_button_pressed() -> void:
	SignalBus.countdown.rpc("go!", 1.0, true)
