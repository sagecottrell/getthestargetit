class_name Client
extends Node

static var PlayerInformation: PlayerInfo

var client_gui_scene = preload("res://client/client_gui.tscn")
var gui: ClientGUI

func _on_multiplayer_on_client(info: PlayerInfo) -> void:
	# on the client side, when the client starts up
	gui = client_gui_scene.instantiate()
	add_child(gui)
	PlayerInformation = info
	
	gui.on_waiting_room()
	
	SignalBus.on_local_win.connect(SignalBus.client_won.rpc_id.bind(1))
	SignalBus.on_recieve_scene_text.connect(_on_recieve_scene_text)
	SignalBus.on_server_changing_level.connect(pre_level_push)
	multiplayer.server_disconnected.connect(_on_server_disconnect)
	
	print('on client')
	SignalBus.c_player_setup.rpc_id(1, info.to_json())

func _on_server_disconnect():
	queue_free()

func pre_level_push():
	gui.on_levelswitch()

func _on_recieve_scene_text(text: String):
	SignalBus.change_scene(Str2Node.tscn_string_to_node(text))
	gui.on_ingame()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_end"):
		SignalBus.pause()
