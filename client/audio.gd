extends Node

@onready var countdown: AudioStreamPlayer = $countdown
@onready var die: AudioStreamPlayer = $die
@onready var music: AudioStreamPlayer = $music
@onready var winorlose: AudioStreamPlayer = $winorlose
@onready var teammatedied: AudioStreamPlayer = $teammatedied
@onready var checkpointget : AudioStreamPlayer = $checkpointget

var cooperative := false

func _ready():
	SignalBus.on_client_won.connect(_on_client_won)
	SignalBus.on_set_game_coop.connect(func(): cooperative = true)
	SignalBus.on_set_game_versus.connect(func(): cooperative = false)

func _on_client_won(pid: int):
	if pid == multiplayer.get_unique_id() or cooperative:
		winorlose.set("parameters/switch_to_clip", "Win")
	else:
		winorlose.set("parameters/switch_to_clip", "Lose")
	winorlose.play()
