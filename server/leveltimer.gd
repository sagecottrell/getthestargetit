extends Timer

func _enter_tree() -> void:
	SignalBus.on_change_scene.connect(_on_change_scene)

func _ready():
	SignalBus.s_on_set_time.connect(_set_time)
	SignalBus.s_on_resume_timer.connect(_on_resume)
	SignalBus.s_on_pause_timer.connect(func(): paused = true)

func _set_time(t: int):
	level_time = t

func _on_resume():
	if is_stopped():
		start_level_timer()
	else:
		paused = false

func _on_change_scene(node: BaseScene):
	level_time = node.timer
# ============================================================================
# level timer
# ============================================================================

func start_level_timer():
	if not timeout.is_connected(_on_timer_tick):
		timeout.connect(_on_timer_tick)
	start()
	SignalBus.timer_change.rpc(level_time)

	
var level_time: int = 0
func _on_timer_tick():
	level_time -= 1
	if level_time < 0:
		stop()
		timeout.disconnect(_on_timer_tick)
		SignalBus.s_game_over("Time's Up!")
	else:
		SignalBus.timer_change.rpc(level_time)
