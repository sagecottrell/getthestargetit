extends Node

signal deactivated()
signal activated()

func deactivate():
	if process_mode != Node.PROCESS_MODE_DISABLED:
		process_mode = Node.PROCESS_MODE_DISABLED
		deactivated.emit()
	
func activate():
	if process_mode != Node.PROCESS_MODE_INHERIT:
		process_mode = Node.PROCESS_MODE_INHERIT
		activated.emit()
