extends Node3D


static var PlayerIds: Dictionary[int, PlayerInfo] = {}
static var PlayerList: Array[int] = []

func _ready() -> void:
	$ServerGUI.visible = false
	$ClientGUI.visible = false

func pack_and_send(fp: String):
	var file = FileAccess.open(fp, FileAccess.READ)
	push_scene_to_all.rpc(file.get_as_text())
	
	var world = Str2Node.tscn_string_to_node(file.get_as_text())
	change_scene(world)
	await get_tree().create_timer(1).timeout
	spawn_players(world)

@rpc()
func push_scene_to_all(txt: String):
	change_scene(Str2Node.tscn_string_to_node(txt))

func change_scene(scene: Node):
	var world = $World
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	
	world.add_child(scene)
	$MultiplayerSpawner.set_spawn_path(scene.get_path())

func _on_multiplayer_on_client() -> void:
	# on the client side, when the client starts up
	$ClientGUI.visible = true
	$DirectoryWatcher.queue_free()
	
	var info: PlayerInfo = $Multiplayer.get_playerinfo()
	send_player_info.rpc(info.to_json())

@rpc("any_peer")
func send_player_info(json: String):
	# The server knows who sent the input.
	var sender_id = multiplayer.get_remote_sender_id()
	var info: PlayerInfo = PlayerInfo.from_json(json)
	PlayerIds[sender_id] = info
	PlayerList.append(sender_id)
	
	var display: PlayerInfoDisplay = preload("res://server/PlayerInfoDisplay.tscn").instantiate()
	display.set_info(info)
	%PlayerList.add_child(display)

func _on_client_connect(id: int):
	prints("client connected:", id)

func _on_multiplayer_on_host() -> void:
	# on the server side, when the server starts up
	$ServerGUI.visible = true
	multiplayer.peer_connected.connect(_on_client_connect)


func spawn_players(world: Node3D):
	var spawns: Array[Node3D] = []
	for child in world.get_children():
		if child is PlayerSpawn:
			spawns.append(child)
	prints("PlayerList", PlayerList)
	for player_id in PlayerList:
		add_player(world, player_id)
	for pair in Zip.zip(spawns, get_tree().get_nodes_in_group("Player"), false):
		var spawn = pair[0]
		var player: Player = pair[1]
		player.position = spawn.position
	

func add_player(world: Node3D, peer_id: int):
	var has_id = peer_id in get_tree().get_nodes_in_group("Player").map(func(node): int(node.name))
	if has_id:
		return
	
	var player_scene = preload("res://prefabs/player/Player.tscn")
	var player: Node3D = player_scene.instantiate()
	player.add_to_group("Player")
	player.name = str(peer_id)
	# player.global_transform = spawn.global_transform
	world.add_child(player)
