class_name HealthManager
extends Node

signal on_die()
signal on_hurt(amount: int)
signal current_hp(max: int, amount: int)

signal on_invuln_start()
signal on_invuln_end()

@export var invulnerable: bool = false

@export var BaseMaxHP: int = 3
@export var MaxHP: int = 3
@export var CurrentHP: int = 3

func _ready():
	publish_current.call_deferred()
	
func publish_current():
	current_hp.emit(MaxHP, CurrentHP)

func reset():
	MaxHP = BaseMaxHP
	CurrentHP = MaxHP
	publish_current()

func heal(amount: int = 1, exceed_max: bool = false):
	if amount < 0:
		CurrentHP = MaxHP
	else:
		CurrentHP += amount
	if not exceed_max:
		CurrentHP = min(CurrentHP, MaxHP)
	current_hp.emit(MaxHP, CurrentHP)

func hurt(amount: int = 1, ignore_invuln: bool = false):
	if not ignore_invuln and invulnerable:
		return
	if amount <= 0:
		return
	CurrentHP -= amount
	on_hurt.emit(amount)
	current_hp.emit(MaxHP, CurrentHP)
	if CurrentHP <= 0:
		CurrentHP = 0
		on_die.emit()

var invuln_timer: SceneTreeTimer
func set_invulnerable(add_time: float):
	if not invulnerable:
		on_invuln_start.emit()
		invulnerable = true
	if add_time < 0:
		if invuln_timer:
			invuln_timer.timeout.disconnect(_end_invuln)
			invuln_timer.time_left = 0
		return
	if invuln_timer:
		invuln_timer.time_left += add_time
		return
	if is_inside_tree():
		invuln_timer = get_tree().create_timer(add_time)
		invuln_timer.timeout.connect(_end_invuln)

func _end_invuln():
	on_invuln_end.emit()
	SignalBus.player_set_invulnerable(false)
	invulnerable = false
	invuln_timer = null

func kill():
	CurrentHP = 0
	current_hp.emit(MaxHP, 0)
	on_invuln_end.emit()
	on_die.emit()
