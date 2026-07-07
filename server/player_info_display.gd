class_name PlayerInfoDisplay extends Control

func _ready():
	$HBoxContainer/SwitchCamButton.visible = false
	SignalBus.on_change_scene.connect(_on_change_scene)
	SignalBus.on_server_changing_level.connect(_on_changing_level)
	reset()

func reset():
	%place.visible = false
	%ready.visible = false

func _on_change_scene(_node):
	$HBoxContainer/SwitchCamButton.visible = true

func _on_changing_level():
	$HBoxContainer/SwitchCamButton.visible = false

func set_info(info: PlayerInfo):
	%place.visible = false
	%label.text = "Player: %s" % [info.name2bbcode()]

func set_place(n: String):
	%place.visible = true
	%place.text = n

func _on_switch_cam_button_pressed() -> void:
	SignalBus.cam_switch(name.to_int(), false)

func _on_client_ready():
	%ready.visible = true
