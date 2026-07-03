class_name PlayerEventsLogic
extends Node

signal killed()
signal respawned()

signal damaged(amount: int)
signal jumped()

signal restored_movement()
signal restricted_movement()

func _ready():
	SignalBus.on_killed.connect(killed.emit)
	SignalBus.on_respawn.connect(respawned.emit)
	SignalBus.on_hurt.connect(damaged.emit)
	SignalBus.restricted_movement.connect(restricted_movement.emit)
	SignalBus.restored_movement.connect(restored_movement.emit)
	SignalBus.on_jumped.connect(jumped.emit)

func restrict_movement():
	SignalBus.restrict_movement()

func restore_movement():
	SignalBus.restore_movement()

func lock_physics():
	SignalBus.player_set_physics_lock(true)

func unlock_physics():
	SignalBus.player_set_physics_lock(false)

func kill():
	SignalBus.die()

func teleport(to: Node3D):
	SignalBus.teleport_to(to)

func impulse(v: Vector3):
	SignalBus.set_player_v(v)

func firstperson():
	SignalBus.force_firstperson()

func thirdperson():
	SignalBus.force_thirdperson()

func show_hint(hint: String, time: float = 3.0):
	SignalBus.player_show_hint(hint, time)

func invulnerable(add_time: float = 3):
	SignalBus.player_set_invulnerable(add_time)
