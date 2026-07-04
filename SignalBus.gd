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

## set the starting timer
signal s_on_set_time(amt: int)
func s_set_time(amt: int):
	s_on_set_time.emit(amt)

signal s_on_pause_timer()
func s_pause_timer():
	s_on_pause_timer.emit()

signal s_on_resume_timer()
func s_resume_timer():
	s_on_resume_timer.emit()

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
func kill():
	hurt(100, true)

## when the local player has died
signal on_killed()
func killed():
	on_killed.emit()

## when the local player gets hurt
signal on_hurt(amount: int, ignore_invuln: bool)
func hurt(amount: int = 1, ignore_invuln: bool = false):
	on_hurt.emit(amount, ignore_invuln)

signal on_heal(amount: int, ignore_max:bool)
func heal(amount: int, ignore_max: bool = false):
	on_heal.emit(amount, ignore_max)

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

## emit to restore player movement
signal restored_movement()
func restore_movement():
	restored_movement.emit()

## emit to restrict player movement
signal restricted_movement()
func restrict_movement():
	restricted_movement.emit()

## emitted after the player jumps
signal on_jumped()
func jumped():
	on_jumped.emit()

signal on_teleport_player_to(target: Node3D)
func teleport_player_to(target: Node3D):
	if target.is_inside_tree():
		on_teleport_player_to.emit(target)

signal on_set_player_v(v: Vector3)
func set_player_v(v: Vector3):
	on_set_player_v.emit(v)

signal on_force_thirdperson()
func force_thirdperson():
	on_force_thirdperson.emit()
	
signal on_force_firstperson()
func force_firstperson():
	on_force_firstperson.emit()

signal on_player_show_hint(hint: String, time: float)
func player_show_hint(hint: String, time: float = 3.0):
	on_player_show_hint.emit(hint, time)

signal on_player_show_interactable_text(hint: String, time: float)
func player_show_interactable_text(hint: String, time: float = .1):
	on_player_show_interactable_text.emit(hint, time)

## set if player physics are locked (gravity, collision)
signal on_player_set_physics_lock(locked: bool)
func player_set_physics_lock(locked: bool):
	on_player_set_physics_lock.emit(locked)

signal on_player_invulnerable(add_time: float)
func player_set_invulnerable(add_time: float = 3):
	on_player_invulnerable.emit(add_time)

# ================================================================================================
# RPC auth-client to server
# ================================================================================================

signal on_player_setup(pid: int, info: PlayerInfo)
@rpc("any_peer")
func c_player_setup(json: String):
	var pid = multiplayer.get_remote_sender_id()
	on_player_setup.emit(pid, PlayerInfo.from_json(json))
	
## when a client submits a win
signal on_client_won(pid: int)
@rpc("any_peer")
func client_won():
	on_client_won.emit(multiplayer.get_remote_sender_id())

# ================================================================================================
# RPC server to auth-client
# ================================================================================================

@rpc()
func s_force_thirdperson():
	force_thirdperson()
	
@rpc()
func s_force_firstperson():
	force_firstperson()

@rpc()
func s_show_hint(hint: String, time: float = 3.0):
	player_show_hint(hint, time)

@rpc()
func s_player_set_physics_lock(locked: bool):
	on_player_set_physics_lock.emit(locked)

@rpc()
func s_kill():
	kill()

@rpc()
func s_hurt(amount: int = -1, ignore_invuln: bool = false):
	hurt(amount, ignore_invuln)
	
@rpc()
func s_heal(amount: int = -1, ignore_max: bool = false):
	heal(amount, ignore_max)

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

signal on_reset_rankings()
@rpc("call_local")
func reset_rankings():
	on_reset_rankings.emit()

## show a countdown in the middle of the screen. will be called multiple times
## length is the maximum mount of time to display this text. must greater than zero. newer countdowns will hide this early
signal on_countdown(display: String, length: float)
@rpc("call_local")
func s_countdown(display: String, length: float):
	on_countdown.emit(display, length)

## let the clients know that the server is planning on changing the level
signal on_server_changing_level()
@rpc("call_local")
func server_changing_level():
	on_server_changing_level.emit()

## update the level timer
signal on_timer_change(time: int)
@rpc("call_local")
func timer_change(time: int):
	on_timer_change.emit(time)

## when the server ends the game, with text to display
signal on_game_over(text: String)
@rpc("call_local")
func s_game_over(text: String):
	on_game_over.emit(text)

## when the server starts the game
signal on_game_start()
@rpc("call_local")
func s_game_start():
	on_game_start.emit()
	
# ================================================================================================
# ================================================================================================


signal on_change_scene(node: BaseScene)
func change_scene(node: BaseScene):
	on_change_scene.emit(node)

signal on_pause()
func pause():
	on_pause.emit()

signal on_unpause()
func unpause():
	on_unpause.emit()
