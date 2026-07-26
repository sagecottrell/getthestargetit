extends Control


func _ready():
	_on_scale_on_value_change(SettingsManager.graphics_3dscale)
	_on_main_audio_on_value_change(SettingsManager.audio_master_volume)
	_on_sfx_on_value_change(SettingsManager.audio_sfx_volume)
	_on_music_on_value_change(SettingsManager.audio_music_volume)

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
	SettingsManager.graphics_3dscale = value
	%Graphics/Scale.Value = value

# ============================================================================
# audio
# ============================================================================


func _on_main_audio_on_value_change(value: float) -> void:
	SettingsManager.audio_master_volume = value
	print(SettingsManager.audio_master_volume)
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus_index, value / 100.0)
	%Audio/MainAudio.Value = value

func _on_sfx_on_value_change(value: float) -> void:
	SettingsManager.audio_sfx_volume = value
	var bus_index = AudioServer.get_bus_index("Sounds")
	AudioServer.set_bus_volume_linear(bus_index, value / 100.0)
	%Audio/SFX.Value = value

func _on_music_on_value_change(value: float) -> void:
	SettingsManager.audio_music_volume = value
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(bus_index, value / 100.0)
	%Audio/Music.Value = value
