extends VBoxContainer

signal player_selected(pid: int)

func _ready():
	SignalBus.on_player_setup.connect(_on_add_player)

func _on_add_player(pid: int, info: PlayerInfo):
	prints('add player', pid, info.name)
	var display = preload("res://server/admin/AdminPlayerInfo.tscn").instantiate()
	display.set_info(info)
	player_selected.connect(display.on_any_selected)
	display.on_click.connect(func(): 
		player_selected.emit(pid)
		display.select()
	)
	display.name = str(pid)
	add_child(display)
