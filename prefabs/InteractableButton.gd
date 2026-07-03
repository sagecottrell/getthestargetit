class_name InteractableButton
extends Area3D

# Emitted when the player interacts with the button
signal button_pressed

signal on_enabled()
signal on_disabled()

@export var prompt_message := "Press E to interact"
@export var disabled_message := "disabled"
@export var enabled: bool = true

# This function is called by the player's raycast script
func interact() -> void:
	if enabled:
		emit_signal("button_pressed")
	else:
		SignalBus.player_show_interactable_text(disabled_message)

func hover():
	if enabled:
		SignalBus.player_show_interactable_text(prompt_message)
	else:
		SignalBus.player_show_interactable_text(disabled_message)

func enable():
	if not enabled:
		enabled = true
		on_enabled.emit()

func disable():
	if enabled:
		enabled = false
		on_disabled.emit()

func set_button_enabled(e: bool):
	if e:
		enable()
	else:
		disable()
