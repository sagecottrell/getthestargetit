extends StaticBody3D

signal player_collide(body: Node3D)

func _on_deathplane_body_entered(body: Node3D) -> void:
	if body is Player:
		player_collide.emit(body)
