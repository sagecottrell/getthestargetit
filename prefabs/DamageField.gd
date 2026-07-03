class_name DamageField
extends Area3D

@export_category("Damage")
@export var player_damage: int = 1
@export var tick_cooldown: float = 1

var player_inside: bool = false
var tick_timer: float = 0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_mask = 2 # players

func _process(delta: float) -> void:
	if player_inside:
		tick_timer += delta
		if tick_timer >= tick_cooldown:
			tick_timer -= tick_cooldown
			SignalBus.hurt(player_damage)

func _on_body_entered(body: Node3D) -> void:
	if body is Player and body.is_multiplayer_authority():
		SignalBus.hurt(player_damage)
		player_inside = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player and body.is_multiplayer_authority():
		player_inside = false
