class_name RedCoin
extends Node3D

signal on_collected()

var collected: bool = false
var cooperative: bool = false

func _ready():
	$blockbench_export/AnimationPlayer.play("spin")
	$Area3D.body_entered.connect(_on_body_enter)
	SignalBus.on_set_game_coop.connect(_on_coop)
	SignalBus.on_set_game_versus.connect(_on_versus)

func _on_body_enter(body: Node3D):
	if body is Player and (cooperative or body.is_multiplayer_authority()):
		collect()
		
func _on_versus():
	cooperative = false

func _on_coop():
	cooperative = true
	
func collect():
	if collected:
		return
	collected = true
	SignalBus.red_coin_collected(self)
	on_collected.emit()
	visible = false
	if check_all_coins():
		$AllPickedupAudio.play()
	else:
		$PickupAudio.play()

func check_all_coins():
	for coin in get_tree().get_nodes_in_group("redcoin"):
		if coin is not RedCoin:
			if coin.visible:
				return
		if coin is RedCoin:
			if not coin.collected:
				return
	
	SignalBus.all_red_coins_collected()
	return true
