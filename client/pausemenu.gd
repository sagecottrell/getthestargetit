extends Control


func _ready():
	_on_scale_on_value_change(SettingsManager.graphics_3dscale)

# ============================================================================
# unstuck
# ============================================================================

func _on_unstuck_button_pressed() -> void:
	SignalBus.unstuck()

# ============================================================================
# scale change
# ============================================================================

func _on_scale_on_value_change(value: float) -> void:
	var new_scale = value / 100.0
	get_viewport().scaling_3d_scale = new_scale
	SettingsManager.graphics_3dscale = new_scale

# ============================================================================
# audio
# ============================================================================


func _on_main_audio_on_value_change(value: float) -> void:
	SettingsManager.audio_master_volume = value
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus_index, value / 100)

func _on_sfx_on_value_change(value: float) -> void:
	SettingsManager.audio_sfx_volume = value
	var bus_index = AudioServer.get_bus_index("Sounds")
	AudioServer.set_bus_volume_linear(bus_index, value / 100)

func _on_music_on_value_change(value: float) -> void:
	SettingsManager.audio_sfx_volume = value
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(bus_index, value / 100)
