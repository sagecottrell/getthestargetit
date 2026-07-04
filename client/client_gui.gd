class_name ClientGUI
extends CanvasLayer

@onready var levelswitch = $levelswitch
@onready var waitingroom: Control = $waitingroom
@onready var ingame: Control = $ingame
@onready var countdownlabel = $ingame/countdownDisplay
@onready var urdead = $ingame/urdead
@onready var respawn_timer_display = %RespawnTimerDisplay
@onready var hint_display = %HintDisplay
@onready var interactable_display = %InteractableDisplay
@onready var timer_display = %TimerDisplay

func _ready() -> void:
	levelswitch.visible = false
	waitingroom.visible = false
	ingame.visible = false
	%TimerDisplay.text = ""
	
	urdead.visible = false
	SignalBus.on_countdown.connect(_on_countdown)
	SignalBus.on_respawn_timer.connect(_on_respawn_timer)
	SignalBus.on_killed.connect(on_playerdead)
	SignalBus.on_respawn.connect(on_playerlive)
	SignalBus.on_player_show_hint.connect(_manage_hint)
	SignalBus.on_player_show_interactable_text.connect(_manage_interactable)
	SignalBus.on_timer_change.connect(func (t): timer_display.text = TimeHelpers.format_seconds(t))
	SignalBus.on_game_over.connect(func (s): timer_display.text = s)

func on_waiting_room():
	levelswitch.visible = false
	waitingroom.visible = true
	ingame.visible = false

func on_ingame():
	levelswitch.visible = false
	waitingroom.visible = false
	ingame.visible = true

func on_levelswitch():
	levelswitch.visible = true
	waitingroom.visible = false
	ingame.visible = false

# ============================================================================
# countdown
# ============================================================================


var countdown_tween: Tween
func _on_countdown(display: String, length: float):
	countdownlabel.visible = true
	countdownlabel.text = display
	if countdown_tween:
		countdown_tween.kill()
	countdown_tween = create_tween()
	countdown_tween.tween_interval(length)
	countdown_tween.tween_callback(_on_countdown_finish)

func _on_countdown_finish():
	countdownlabel.visible = false

# ============================================================================
# player death
# ============================================================================

func on_playerdead():
	urdead.visible = true

func on_playerlive():
	urdead.visible = false

func _on_respawn_timer(left: float, max_time: float):
	respawn_timer_display.max_value = max_time * 100
	respawn_timer_display.value = (max_time - left) * 100


# ============================================================================
# hint
# ============================================================================

var hint_timer: SceneTreeTimer
var interactable_timer: SceneTreeTimer

func _manage_interactable(hint: String, time: float):
	interactable_display.text = hint
	if interactable_timer:
		interactable_timer.time_left = time
		return
	interactable_timer = get_tree().create_timer(time)
	await interactable_timer.timeout
	interactable_display.text = ""
	interactable_timer = null

func _manage_hint(hint: String, time: float):
	hint_display.text = hint
	if hint_timer:
		hint_timer.time_left = time
		return
	hint_timer = get_tree().create_timer(time)
	await hint_timer.timeout
	hint_display.text = ""
	hint_timer = null
