extends Node3D

signal collide()

var is_available: bool = true

# radians per second
@export var rotate_speed : float = 4

func _ready():
	SignalBus.on_game_over.connect(_on_gameover)

func _process(delta: float) -> void:
	$star.rotate_y(delta * rotate_speed)

func _on_gameover(_d):
	is_available = false

func on_collide(area: Node3D):
	if area is Player:
		if is_available and area.is_multiplayer_authority():
			collide.emit(area)
			SignalBus.local_win()
			queue_free()
		else:
			spinfast()

var spintween: Tween
func spinfast(factor: float = 2, duration: float = 2):
	if spintween and spintween.is_running():
		spintween.stop()
		spintween.custom_step(duration)
		
	var target_speed = rotate_speed
	rotate_speed *= factor
	spintween = create_tween()
	spintween.tween_property(self, "rotate_speed", target_speed, duration)
