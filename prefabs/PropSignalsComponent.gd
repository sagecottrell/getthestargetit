class_name PropSignalsComponent
extends Node

@export var start_active: bool = true

@export var emit_signals_on_ready: bool = false

signal deactivated()
signal activated()

signal moved(target: Node3D)
signal rotated(target: Node3D)

var parent: Node3D

func _ready():
	parent = get_parent()
	if emit_signals_on_ready:
		if start_active:
			activate()
		else:
			deactivate()
	else:
		if start_active:
			parent.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			parent.process_mode = Node.PROCESS_MODE_DISABLED

func deactivate():
	if parent.process_mode != Node.PROCESS_MODE_DISABLED:
		parent.process_mode = Node.PROCESS_MODE_DISABLED
		deactivated.emit()
	
func activate():
	if parent.process_mode != Node.PROCESS_MODE_INHERIT:
		parent.process_mode = Node.PROCESS_MODE_INHERIT
		activated.emit()

func move_to(target: Node3D):
	parent.global_position = target.global_position
	moved.emit(target)

func copy_rotation(target: Node3D):
	parent.global_rotation = target.global_rotation
	rotated.emit(target)
