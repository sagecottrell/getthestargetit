extends Node3D

signal on_collected()

var plane: MeshInstance3D
@export var owned_material: StandardMaterial3D

var collected: bool = false
var cooperative: bool = false

var player : Node3D

func _ready():
	plane = find_child("plane")
	$Area3D.body_entered.connect(_on_body_enter)
	SignalBus.on_checkpoint_collected.connect(_on_cp_collected)
	SignalBus.on_set_game_coop.connect(_on_coop)
	SignalBus.on_set_game_versus.connect(_on_versus)

func _process(_delta):
	if player:
		if not player.global_position.is_equal_approx(global_position):
			look_at(player.global_position)
			rotation_degrees.x = 0
			rotation_degrees.z = 0
	else:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

func _on_versus():
	cooperative = false

func _on_coop():
	cooperative = true
	
func _on_body_enter(body: Node3D):
	if body is Player and (cooperative or body.is_multiplayer_authority()):
		collect()

func collect():
	$blockbench_export/AnimationPlayer.play("get")
	
	if not collected:
		SignalBus.checkpoint_collected(self)
		on_collected.emit()

func _on_cp_collected(cp: Node3D):
	if cp == self and Client.PlayerInformation != null:
		owned_material.albedo_color = Client.PlayerInformation.color
		owned_material.emission = Client.PlayerInformation.color
		owned_material.stencil_color = Client.PlayerInformation.color
		plane.set_surface_override_material(0, owned_material)
		SignalBus.player_show_hint(String(name) + " Collected!")
		collected = true
	else:
		plane.set_surface_override_material(0, null)
		collected = false
	$marker.visible = collected
