extends Control

signal on_click()

var player_info: PlayerInfo
var selected_paneltheme: StyleBox

func _ready():
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	var paneltheme = get_theme_stylebox("panel")
	if paneltheme is StyleBoxFlat:
		selected_paneltheme = paneltheme.duplicate()
		selected_paneltheme.bg_color = player_info.color
		

func _on_peer_disconnect(pid: int):
	if pid == name.to_int():
		queue_free()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			on_click.emit()

func set_info(info: PlayerInfo):
	player_info = info
	%label.text = info.name2bbcode()

func on_any_selected(pid: int):
	if pid != name.to_int():
		deselect()

func select():
	add_theme_stylebox_override("panel", selected_paneltheme)

func deselect():
	remove_theme_stylebox_override("panel")
