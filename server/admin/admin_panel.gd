extends Control

@onready var player_controls = %PlayerControls

var player_list: Dictionary[int, PlayerInfo] = {}
var selected_player: int 

func _ready():
	SignalBus.on_player_setup.connect(_on_player_setup)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	$Confirmation.on_cancel.connect(cancel_confirmation)
	
	player_controls.on_kick.connect(kick)
	player_controls.on_respawn.connect(respawn)
	player_controls.on_heal.connect(heal)
	player_controls.on_hurt.connect(hurt)
	

func _on_player_setup(pid: int, info: PlayerInfo):
	player_list[pid] = info

func _on_peer_disconnect(pid: int):
	player_list.erase(pid)
	
func select_player(pid: int):
	selected_player = pid
	
func heal(amt: int, b: bool):
	if selected_player not in player_list:
		return
	SignalBus.s_heal.rpc_id(selected_player, amt, b)
	
func hurt(amt: int, b: bool):
	if selected_player not in player_list:
		return
	SignalBus.s_hurt.rpc_id(selected_player, amt, b)

func kick():
	if selected_player not in player_list:
		return
	var kick_confirm = func():
		multiplayer.multiplayer_peer.disconnect_peer(selected_player)
		hide_confirmation()
	$Confirmation.popup("kick " + player_list[selected_player].name)
	$Confirmation.on_confirm.connect(kick_confirm)


func respawn():
	if selected_player not in player_list:
		return
	SignalBus.s_kill.rpc_id(selected_player)

# =================================================================

func cancel_confirmation():
	hide_confirmation()

func hide_confirmation():
	$Confirmation.visible = false
	$Confirmation.disconnect_all_from_confirm()
