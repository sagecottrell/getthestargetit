extends Control

@onready var prefab = $prefab

func _enter_tree() -> void:
	SignalBus.on_red_coin_collected.connect(_on_collected)
	SignalBus.on_change_scene.connect(discover_coins)

func _ready():
	prefab.visible = false

func discover_coins(_node):
	for i in range(1, get_child_count()):
		get_child(i).queue_free()
	for coin in get_tree().get_nodes_in_group("redcoin"):
		if coin is RedCoin:
			var new = prefab.duplicate()
			new.visible = true
			new.get_child(1).visible = false
			add_child(new)

func _on_collected(_coin: Node3D):
	var m = get_child_count()
	for i in range(1, m):
		var child = get_child(i)
		var full: Control = child.get_child(1)
		if not full.visible:
			full.visible = true
			return
