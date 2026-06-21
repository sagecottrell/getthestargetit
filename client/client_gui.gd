class_name ClientGUI
extends CanvasLayer

@onready var levelswitch = $levelswitch
@onready var waitingroom: Control = $waitingroom
@onready var ingame: Control = $ingame
@onready var countdownlabel = $ingame/Label

func _ready() -> void:
	levelswitch.visible = false
	waitingroom.visible = false
	ingame.visible = false
	SignalBus.on_countdown.connect(_on_countdown)

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
func _on_countdown(display: String, length: float, _final: bool):
	countdownlabel.visible = true
	countdownlabel.text = display
	if countdown_tween:
		countdown_tween.kill()
	countdown_tween = create_tween()
	countdown_tween.tween_interval(length)
	countdown_tween.tween_callback(_on_countdown_finish)

func _on_countdown_finish():
	countdownlabel.visible = false
