extends VBoxContainer

signal on_kick()
signal on_respawn()

func kick():
	on_kick.emit()

func respawn():
	on_respawn.emit()
