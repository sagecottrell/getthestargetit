class_name GameEvents
extends Node

signal on_game_over()

signal on_all_red_coins_collected()

func _ready():
	SignalBus.on_game_over.connect(func (_t): on_game_over.emit())
	SignalBus.on_all_red_coins_collected.connect(on_all_red_coins_collected.emit)
