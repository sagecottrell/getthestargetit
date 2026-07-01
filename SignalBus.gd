extends Node

## functions are prefixed according to who is allowed to call the function:
# s for server
# ac for authoritative client over the current node
# nc for non-authoritative client over the current node
# - note: this category will probably not be used, as clients will not react to anything that other players do
# c for any client
# a for all, both server and all clients

# ================================================================================================
# NORPC server to server
# ================================================================================================

## when the user selects "host", this signal is emitted to tell things that we are now a host
signal on_self_is_server()
func s_self_is_server():
	on_self_is_server.emit()

signal s_on_file_press_send(fp: String)
func s_file_press_send(fp: String):
	s_on_file_press_send.emit(fp)

## when the server wants to switch to a camera
## pid 1 to switch level cameras, otherwise to get player cameras
## for players, increase=true to get fp, false to get freecam
## for level cameras, increase to move to next, otherwise prev
signal on_cam_switch(pid: int, increase: bool)
func cam_switch(pid: int, increase: bool):
	on_cam_switch.emit(pid, increase)

# ================================================================================================
# NORPC auth-client to auth-client
# ================================================================================================

## when the user selects "connect", this signal is emitted to tell things that we are now a client
signal on_self_is_client()
func c_self_is_client():
	on_self_is_client.emit()

## when the local player first reaches the goal
signal on_local_win()
func local_win():
	on_local_win.emit()

## when the local player wants to get unstuck
signal on_unstuck()
func unstuck():
	on_unstuck.emit()

## when the local player should die
signal on_die()
func die():
	on_die.emit()
	
## when the local player gets hurt
signal on_hurt(amount: int)
func hurt(amount: int = 1):
	on_hurt.emit(amount)
	
## when the player hp changes, use this to inform the rest of the application and other clients
signal on_client_player_hp(max_hp: int, amount: int)
func client_player_hp(max_hp: int, amount: int):
	on_client_player_hp.emit(max_hp, amount)

signal on_respawn_timer(time_left: float, max_time: float)
func respawn_timer(time_left: float, max_time: float):
	on_respawn_timer.emit(time_left, max_time)
	
signal on_respawn()
func respawn():
	on_respawn.emit()

# ================================================================================================
# RPC auth-client to server
# ================================================================================================

signal c_on_player_setup(pid: int, json: String)
@rpc("any_peer")
func c_player_setup(json: String):
	var pid = multiplayer.get_remote_sender_id()
	c_on_player_setup.emit(pid, json)
	
## when a client submits a win
signal on_client_won(pid: int)
@rpc("any_peer")
func client_won():
	on_client_won.emit(multiplayer.get_remote_sender_id())

# ================================================================================================
# RPC server to auth-client
# ================================================================================================

# ================================================================================================
# RPC server to all clients
# ================================================================================================

signal on_recieve_scene_text(node: String)
@rpc("call_local")
func recieve_scene_text(node: String):
	on_recieve_scene_text.emit(node)

## when any connected player reaches the goal, including the local player
signal on_any_win(pid: int, place: String)
@rpc("call_local")
func any_win(pid: int, place: String):
	on_any_win.emit(pid, place)

## show a countdown in the middle of the screen. will be called multiple times
## length is the maximum mount of time to display this text. must greater than zero. newer countdowns will hide this early
## final=true for the last part of the countdown (usually a "GO!" or something)
signal on_countdown(display: String, length: float, final: bool)
@rpc("call_local")
func countdown(display: String, length: float, final: bool):
	on_countdown.emit(display, length, final)

## let the clients know that the server is planning on changing the level
signal on_server_changing_level()
@rpc("call_local")
func server_changing_level():
	on_server_changing_level.emit()


# ================================================================================================
# ================================================================================================


signal on_change_scene(node: BaseScene)
func change_scene(node: BaseScene):
	on_change_scene.emit(node)
