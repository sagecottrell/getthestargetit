extends VBoxContainer

signal on_kick()
signal on_respawn()
signal on_heal(amt: int, nocap: bool)
signal on_hurt(amt: int, always: bool)

func kick():
	on_kick.emit()

func respawn():
	on_respawn.emit()


func _on_heal_pressed() -> void:
	on_heal.emit($Heal/healamt.value, $Heal/overmax.button_pressed)


func _on_hurt_pressed() -> void:
	on_hurt.emit($Hurt/hurtamt.value, $Hurt/ignoreinvuln.button_pressed)
