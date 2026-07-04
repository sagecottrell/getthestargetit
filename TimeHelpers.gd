class_name TimeHelpers

static func format_seconds(time_in_seconds: int):
	if time_in_seconds < 0:
		return ""
		
	var minutes: int = floor(time_in_seconds / 60.0)
	var seconds: int = int(time_in_seconds) % 60
	if minutes > 0:
		# %02d forces a 2-digit integer with leading zeros
		return "%02d:%02d" % [minutes, seconds]
	else:
		return str(seconds)

static func parse_seconds(time_formatted: String) -> int:
	var parts = time_formatted.split(":")
	match parts:
		[]:
			return 0
		[var s]:
			return int(s)
		[var m, var s]:
			return int(m) * 60 + int(s)
	return -1
