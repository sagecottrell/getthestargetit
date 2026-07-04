class_name GameEvents
extends Node

signal on_game_over()

func _ready():
	SignalBus.on_game_over.connect(func (_t): on_game_over.emit())
