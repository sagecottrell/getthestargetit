class_name PlayerInfoDisplay extends Control

func set_info(info: PlayerInfo):
	$label.text = "Connected Player: [color=#%s]%s[/color]" % [info.color.to_html(false), info.name]
