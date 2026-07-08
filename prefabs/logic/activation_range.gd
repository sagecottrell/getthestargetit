class_name ActivationRange
extends Area3D

signal on_activate()
signal on_deactivate()

var active: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_mask = 2
	monitorable = false
	
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	
	deactivate()

func _on_enter(body: Node3D):
	if not active and body is Player and body.is_multiplayer_authority():
		activate()

func _on_exit(body: Node3D):
	if active and body is Player and body.is_multiplayer_authority():
		deactivate()

func activate():
	get_parent().process_mode = Node.PROCESS_MODE_INHERIT
	if not active:
		on_activate.emit()
	active = true

func deactivate():
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	if active:
		on_deactivate.emit()
	active = false
	
