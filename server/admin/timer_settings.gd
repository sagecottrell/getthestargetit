extends Control

@onready var timercurrent = %TimerCurrent
@onready var setTime = %timeInput
@onready var pausebutton = %pauseresume
@onready var startingTimer = %CurrentStartingTimer

var paused: bool = true

func _ready():
	SignalBus.on_timer_change.connect(func (time): timercurrent.text = TimeHelpers.format_seconds(time, true))
	SignalBus.on_game_over.connect(func (t): timercurrent.text = t)
	setTime.text_submitted.connect(_on_set_time_input_text_submitted)
	SignalBus.s_on_set_time.connect(func (t): startingTimer.text = TimeHelpers.format_seconds(t, true))
	
	_on_pause()
	pausebutton.pressed.connect(toggle_pause)
	SignalBus.s_on_pause_timer.connect(_on_pause)
	SignalBus.s_on_resume_timer.connect(_on_resume)


## ======================================================================================
## ======================================================================================

func _on_set_time_input_text_submitted(new_text: String) -> void:
	var t = TimeHelpers.parse_seconds(new_text)
	if t > 0:
		SignalBus.s_set_time(t)
		setTime.clear()
		_valid(setTime)
	else:
		_wiggle(setTime, 20, 1, 2)
		_invalid(setTime)


func _valid(input: LineEdit):
	input.remove_theme_color_override("font_color")
	
func _invalid(input: LineEdit):
	input.add_theme_color_override("font_color", Color.RED)


func _wiggle(c: Control, wiggle_amount: float, duration: float, count: int):
	var wiggle_speed = duration / count
	var tween = create_tween().set_loops(count) # Loops continuously while hovering
	# A quick, snappy left-to-right wiggle
	tween.tween_property(c, "offset_transform_position:x", + wiggle_amount, wiggle_speed)
	tween.tween_property(c, "offset_transform_position:x", - wiggle_amount, wiggle_speed)

## ======================================================================================
## ======================================================================================

func toggle_pause():
	if paused:
		SignalBus.s_resume_timer()
	else:
		SignalBus.s_pause_timer()

func _on_pause():
	paused = true
	pausebutton.text = "Resume"

func _on_resume():
	paused = false
	pausebutton.text = "Pause"
