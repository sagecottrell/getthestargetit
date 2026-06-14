# multiplayer.gd
extends Node

const PORT = 4433

func _ready():
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()


func _on_host_pressed():
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	print("hosting")
	start_game()


func _on_connect_pressed():
	# Start as client.
	var txt : String = $UI/Net/Options/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	
	$UI.process_mode = Node.PROCESS_MODE_DISABLED
	var t = 0
	while peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED and t < 5:
		await get_tree().create_timer(0.1).timeout
		t += 0.1
	$UI.process_mode = Node.PROCESS_MODE_INHERIT
	
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	print("client connected")
	start_game()


func start_game():
	# Hide the UI and unpause to start the game.
	$UI.hide()
