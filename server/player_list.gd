class_name PlayerListDisplay
extends VBoxContainer

var player_list_items: Dictionary[int, PlayerInfoDisplay] = {}

func _ready():
	SignalBus.on_player_setup.connect(_on_add_player)
	SignalBus.on_any_win.connect(_on_any_won)
	SignalBus.on_reset_rankings.connect(clear_places)

func _on_add_player(pid: int, info: PlayerInfo):
	var display: PlayerInfoDisplay = preload("res://server/PlayerInfoDisplay.tscn").instantiate()
	display.set_info(info)
	display.name = str(pid)
	add_child(display)
	player_list_items[pid] = display

func _on_any_won(pid: int, place: String):
	player_list_items[pid].set_place(place)

func clear_places():
	for child in player_list_items.values():
		child.hide_place()
