class_name PlayerInfo extends RefCounted

var name: String = "player"
var color: Color = Color.RED

func _init(n: String, c: Color):
	name = n
	color = c

func to_json() -> String:
	return JSON.stringify({"name": name, "color": color.to_html()})

static func from_json(s: String) -> PlayerInfo:
	var dict = JSON.parse_string(s)
	return PlayerInfo.new(dict['name'], Color.from_string(dict['color'], Color.RED))
