class_name Client
extends Node

@onready var gui: Node = $ClientGUI
@onready var levelswitch = $ClientGUI/levelswitch
@onready var waitingroom: Control = $ClientGUI/waitingroom
@onready var ingame: Control = $ClientGUI/ingame
@onready var countdownlabel = $ClientGUI/ingame/Label

func _ready() -> void:
	levelswitch.visible = false
	waitingroom.visible = false
	ingame.visible = false
	SignalBus.on_self_is_server.connect(_on_self_is_server)

func _on_multiplayer_on_client(info: PlayerInfo) -> void:
	# on the client side, when the client starts up
	waitingroom.visible = true
	
	SignalBus.on_local_win.connect(player_win.rpc_id.bind(1))
	SignalBus.on_recieve_scene.connect(_on_recieve_scene)
	SignalBus.on_pre_level_push.connect(pre_level_push.rpc)
	SignalBus.on_countdown.connect(_on_countdown)
	multiplayer.server_disconnected.connect(_on_server_disconnect)
	
	print('on client')
	SignalBus.client_setup(info)

func _on_server_disconnect():
	print('server disconnect')

@rpc("any_peer")
func player_win():
	var sender_id = multiplayer.get_remote_sender_id()
	SignalBus.client_won(sender_id)

@rpc()
func pre_level_push():
	levelswitch.visible = true

func _on_recieve_scene(node: BaseScene):
	SignalBus.change_scene(node)
	levelswitch.visible = false
	waitingroom.visible = false
	ingame.visible = true

func _on_self_is_server():
	gui.visible = false


# ============================================================================
# countdown
# ============================================================================


var countdown_tween: Tween
func _on_countdown(display: String, length: float, _final: bool):
	countdownlabel.visible = true
	countdownlabel.text = display
	if countdown_tween:
		countdown_tween.kill()
	countdown_tween = create_tween()
	countdown_tween.tween_interval(length)
	countdown_tween.tween_callback(_on_countdown_finish)

func _on_countdown_finish():
	countdownlabel.visible = false
