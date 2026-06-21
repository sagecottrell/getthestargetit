class_name Server
extends Node

var server_gui_scene = preload("res://server/server_gui.tscn")
var gui: ServerGUI


static var PlayerIds: Dictionary[int, PlayerInfo] = {}
static var PlayerList: Array[int] = []

static var rankings: Array[int] = []

func _ready() -> void:
	multiplayer.server_relay = true
	SignalBus.on_self_is_client.connect(_on_self_is_client)

func _on_multiplayer_on_host() -> void:
	# on the server side, when the server starts up
	gui = server_gui_scene.instantiate()
	add_child(gui)
	
	var saved_watch_dir: String = SettingsManager.load_setting("Server", "watch_path", "")
	if not saved_watch_dir.is_empty():
		gui.dir_watcher.add_scan_directory(saved_watch_dir)
		gui.watch_path.text = saved_watch_dir
	multiplayer.peer_connected.connect(_on_client_connect)
	multiplayer.peer_disconnected.connect(_on_client_disconnect)
	
	SignalBus.on_client_won.connect(_on_client_won)
	SignalBus.on_recieve_scene_text.connect(_on_recieve_scene_text)
	SignalBus.s_on_file_press_send.connect(pack_and_send)
	SignalBus.c_on_player_setup.connect(_on_client_info)

func _on_self_is_client():
	gui.dir_watcher.queue_free()

func _on_client_connect(id: int):
	prints("client connected:", id)

func _on_client_disconnect(id: int):
	prints("client disconnected:", id)
	PlayerIds.erase(id)
	PlayerList.erase(id)
	rankings.erase(id)

func _on_client_info(sender_id: int, json: String):
	# The server knows who sent the input.
	var info: PlayerInfo = PlayerInfo.from_json(json)
	prints("setting up player", sender_id)
	PlayerIds[sender_id] = info
	PlayerList.append(sender_id)
	gui.add_player(sender_id, info)

# ============================================================================
# setup level
# ============================================================================

func _on_recieve_scene_text(text: String):
	SignalBus.change_scene(Str2Node.tscn_string_to_node(text))
	
func pack_and_send(fp: String):
	rankings.clear()
	gui.clear_places()
	
	var file = FileAccess.open(fp, FileAccess.READ)
	SignalBus.pre_level_push.rpc()
	
	await get_tree().create_timer(1).timeout
	
	SignalBus.recieve_scene_text.rpc(file.get_as_text())
	gui.level_controller.visible = true

# ============================================================================
# player reach goal
# ============================================================================

func _on_client_won(pid: int):
	if pid in rankings:
		return
	var n = rankings.size() + 1
	rankings.append(pid)
	var d = {n: str(n) + "th", 1: "1st", 2: "2nd", 3: "3rd"}[n]
	SignalBus.any_win.rpc(pid, d)
