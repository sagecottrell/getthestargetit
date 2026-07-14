extends Node

@onready var countdown: AudioStreamPlayer = $countdown
@onready var die: AudioStreamPlayer = $die
@onready var music: AudioStreamPlayer = $music
@onready var win: AudioStreamPlayer = $win
@onready var lose: AudioStreamPlayer = $lose
@onready var teammatedied: AudioStreamPlayer = $teammatedied
@onready var checkpointget : AudioStreamPlayer = $checkpointget

var cooperative := false

func _ready():
	SignalBus.on_client_won.connect(_on_client_won)
	SignalBus.on_set_game_coop.connect(func(): cooperative = true)
	SignalBus.on_set_game_versus.connect(func(): cooperative = false)
	SignalBus.on_server_changing_level.connect(_on_changing_level)
	SignalBus.on_game_start.connect(_on_game_start)
	SignalBus.on_countdown.connect(_on_countdown)
	SignalBus.on_checkpoint_collected.connect(_on_checkpoint)

func _on_client_won(pid: int):
	music.stop()
	if pid == multiplayer.get_unique_id() or cooperative:
		win.play()
	else:
		lose.play()

func _on_changing_level():
	win.stop()
	lose.stop()
	music.stop()

func _on_game_start():
	music.play()

func _on_countdown(d: String, _f: float):
	if not countdown.playing:
		countdown.play()
	countdown.set("parameters/switch_to_clip", d.to_lower())

func _on_checkpoint(_cp: Node3D):
	checkpointget.play()
