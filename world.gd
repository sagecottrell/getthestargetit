extends Node3D

func _ready() -> void:
	SignalBus.on_change_scene.connect(change_scene)
	SignalBus.on_server_changing_level.connect(server_changing_level)

func change_scene(scene: BaseScene):
	add_child(scene)

func server_changing_level():
	for child in get_children():
		child.queue_free()
