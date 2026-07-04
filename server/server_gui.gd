class_name ServerGUI
extends CanvasLayer

@onready var level_controller: Control = %LevelController
@onready var player_list = %PlayerList
@onready var countdownlabel = %CountdownDisplay
@onready var countdown_sequence_input = %CountdownSequenceInput


func _ready() -> void:
	SignalBus.on_countdown.connect(_on_countdown)
	SignalBus.on_change_scene.connect(_on_change_scene)
	level_controller.visible = false

func _on_change_scene(_node):
	level_controller.visible = true
	$PauseMenu.visible = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$PauseMenu.visible = not $PauseMenu.visible

# ============================================================================
# camera
# ============================================================================


func _on_prev_camera_button_pressed() -> void:
	SignalBus.cam_switch(1, false)


func _on_next_camera_button_pressed() -> void:
	SignalBus.cam_switch(1, true)


# ============================================================================
# countdown
# ============================================================================

func _on_start_countdown_button_pressed() -> void:
	var tree = get_tree()
	var input: String = countdown_sequence_input.text
	var parts = Array(input.split(",")) \
		.map(func(x): return x.strip_edges()) \
		.filter(func(x): return not x.is_empty())
	for i in range(parts.size()):
		var part = parts[i]
		var is_last = i == parts.size() - 1
		SignalBus.countdown.rpc(part, 1.0 if is_last else 3.0, is_last)
		await tree.create_timer(1.0).timeout


var countdown_tween: Tween
func _on_countdown(display: String, length: float, _final: bool):
	countdownlabel.text = display
	if countdown_tween:
		countdown_tween.kill()
	countdown_tween = create_tween()
	countdown_tween.tween_interval(length)
	countdown_tween.tween_callback(_on_countdown_finish)

func _on_countdown_finish():
	countdownlabel.text = ""


func _on_unlock_players_button_pressed() -> void:
	SignalBus.countdown.rpc("go!", 1.0, true)
