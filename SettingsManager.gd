extends Node

const SETTINGS_FILE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready() -> void:
	# Load existing settings on startup, or create defaults if none exist
	if load_settings() != OK:
		save_default_settings()

# Save a setting value under a specific section and key
func save_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	config.save(SETTINGS_FILE_PATH)

# Load a setting value, returning a fallback default if it doesn't exist
func load_setting(section: String, key: String, default_value: Variant) -> Variant:
	return config.get_value(section, key, default_value)

# Generate default configuration if the file is missing
func save_default_settings() -> void:
	graphics_fullscreen = false
	graphics_3dscale = 1
	audio_master_volume = 0.8
	server_watch_path = ""
	server_timer_start = 60
	config.save(SETTINGS_FILE_PATH)

# Load the file from disk
func load_settings() -> Error:
	return config.load(SETTINGS_FILE_PATH)

var graphics_fullscreen: bool:
	set(b):
		config.set_value("Graphics", "fullscreen", b)
	get:
		return config.get_value("Graphics", "fullscreen", true)

var graphics_3dscale: float:
	set(b):
		config.set_value("Graphics", "3dscale", b)
	get:
		return config.get_value("Graphics", "3dscale", 1.0)

var audio_master_volume: float:
	set(b):
		config.set_value("Audio", "master_volume", b)
	get:
		return config.get_value("Audio", "master_volume", .8)

var audio_sfx_volume: float:
	set(b):
		config.set_value("Audio", "sfx", 1)
	get:
		return config.get_value("Audio", "sfx", 1)

var audio_music_volume: float:
	set(b):
		config.set_value("Audio", "music", 1)
	get:
		return config.get_value("Audio", "music", 1)

var server_watch_path: String:
	set(b):
		config.set_value("Server", "watch_path", b)
	get:
		return config.get_value("Server", "watch_path", "")

var server_timer_start: int:
	set(b):
		config.set_value("Server", "timer_start_value", b)
	get:
		return config.get_value("Server", "timer_start_value", 60)
