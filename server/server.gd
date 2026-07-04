class_name Server
extends Node

var server_gui_scene = preload("res://server/server_gui.tscn")
var gui: ServerGUI

static var PlayerIds: Dictionary[int, PlayerInfo] = {}
static var PlayerList: Array[int] = []

static var rankings: Array[int] = []

static var cooperative: bool = false

func _ready() -> void:
	multiplayer.server_relay = true

func _on_multiplayer_on_host() -> void:
	# on the server side, when the server starts up
	gui = server_gui_scene.instantiate()
	add_child(gui)
	
	multiplayer.peer_connected.connect(_on_client_connect)
	multiplayer.peer_disconnected.connect(_on_client_disconnect)
	
	SignalBus.on_client_won.connect(_on_client_won)
	SignalBus.on_recieve_scene_text.connect(_on_recieve_scene_text)
	SignalBus.s_on_file_press_send.connect(pack_and_send)
	SignalBus.on_player_setup.connect(_on_client_info)
	SignalBus.on_set_game_coop.connect(_on_coop)
	SignalBus.on_set_game_versus.connect(_on_versus)

func _on_client_connect(id: int):
	prints("client connected:", id)

func _on_client_disconnect(id: int):
	prints("client disconnected:", id)
	PlayerIds.erase(id)
	PlayerList.erase(id)
	rankings.erase(id)

func _on_client_info(sender_id: int, info: PlayerInfo):
	# The server knows who sent the input.
	prints("setting up player", sender_id)
	PlayerIds[sender_id] = info
	PlayerList.append(sender_id)

func _on_versus():
	cooperative = false
	SignalBus.s_server_message.rpc("Cooperative Disabled")

func _on_coop():
	cooperative = true
	SignalBus.s_server_message.rpc("Cooperative Enabled")
		
# ============================================================================
# setup level
# ============================================================================

func _on_recieve_scene_text(text: String):
	SignalBus.change_scene(Str2Node.tscn_string_to_node(text))
	
func pack_and_send(fp: String):
	rankings.clear()
	SignalBus.reset_rankings.rpc()
	
	var file = FileAccess.open(fp, FileAccess.READ)
	SignalBus.server_changing_level.rpc()
	
	await get_tree().create_timer(1).timeout
	
	SignalBus.recieve_scene_text.rpc(file.get_as_text())
	gui.level_controller.visible = true
	
	if cooperative:
		SignalBus.s_set_game_coop.rpc()

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
