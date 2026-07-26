extends Node

const SETTINGS_FILE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready() -> void:
	# Load existing settings on startup, or create defaults if none exist
	config.load(SETTINGS_FILE_PATH)

# Save a setting value under a specific section and key
func save_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	config.save(SETTINGS_FILE_PATH)

# Load a setting value, returning a fallback default if it doesn't exist
func load_setting(section: String, key: String, default_value: Variant) -> Variant:
	return config.get_value(section, key, default_value)


var graphics_fullscreen: bool:
	set(b):
		save_setting("Graphics", "fullscreen", b)
	get:
		return config.get_value("Graphics", "fullscreen", true)

var graphics_3dscale: float:
	set(b):
		save_setting("Graphics", "3dscale", b)
	get:
		return config.get_value("Graphics", "3dscale", 100)

var audio_master_volume: float:
	set(b):
		save_setting("Audio", "master_volume", b)
	get:
		return config.get_value("Audio", "master_volume", 80)

var audio_sfx_volume: float:
	set(b):
		save_setting("Audio", "sfx", b)
	get:
		return config.get_value("Audio", "sfx", 100)

var audio_music_volume: float:
	set(b):
		save_setting("Audio", "music", b)
	get:
		return config.get_value("Audio", "music", 100)

var client_connect_addr: String:
	set(b):
		save_setting("Client", "connect_addr", b)
	get:
		return config.get_value("Client", "connect_addr", "127.0.0.1:%d" % [MultiplayerInfo.PORT])

var server_watch_path: String:
	set(b):
		save_setting("Server", "watch_path", b)
	get:
		return config.get_value("Server", "watch_path", "")
