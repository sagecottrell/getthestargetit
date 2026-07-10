extends Control

@onready var dmg = $DamageFlash
@onready var heal = $HealFlash

@export var damage_duration: float = 1
@export var healing_duration: float = 1
var damage: float = 0.0
var healing: float = 0.0

func _ready():
	SignalBus.on_hurt.connect(_on_hurt)
	SignalBus.on_heal.connect(_on_heal)
	dmg.modulate.a = 0
	heal.modulate.a = 0

func _on_hurt(_amount: int, _invuln: bool):
	damage = damage_duration

func _on_heal(_amount: int, _b: bool):
	healing = healing_duration
	
func _process(delta):
	if damage > 0:
		damage -= delta
		dmg.modulate.a = damage / damage_duration
	if healing > 0:
		healing -= delta
		heal.modulate.a = healing / healing_duration
