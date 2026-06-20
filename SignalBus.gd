extends Node

## when the local player first reaches the goal
signal on_local_win()

## when any connected player reaches the goal, including the local player
signal on_any_win(pid: int, place: String)

## when the local player wants to get unstuck
signal on_unstuck()

## when the local player should die
signal on_die()



func local_win():
	on_local_win.emit()

func any_win(pid: int, place: String):
	on_any_win.emit(pid, place)

func unstuck():
	on_unstuck.emit()

func die():
	on_die.emit()
