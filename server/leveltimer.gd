extends Timer

func _ready():
	SignalBus.s_on_set_time.connect(_set_time)
	SignalBus.s_on_resume_timer.connect(_on_resume)
	SignalBus.s_on_pause_timer.connect(func(): paused = true)


func _set_time(t: int):
	SettingsManager.save_setting("Server", "timer_start_value", t)


func _on_resume():
	if is_stopped():
		start_level_timer()
	else:
		paused = false

# ============================================================================
# level timer
# ============================================================================

func start_level_timer():
	level_time = SettingsManager.load_setting("Server", "timer_start_value", 60)
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
		SignalBus.s_game_over.rpc("Time's Up!")
	else:
		SignalBus.timer_change.rpc(level_time)
