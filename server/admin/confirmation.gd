extends PanelContainer

signal on_confirm()
signal on_cancel()

func confirm():
	on_confirm.emit()

func cancel():
	on_cancel.emit()

func complete():
	visible = false
	%cancel.release_focus()
	%yes.release_focus()

func popup(action: String):
	%action.text = action
	visible = true
	%cancel.grab_focus()

func disconnect_all_from_confirm() -> void:
	for connection in on_confirm.get_connections():
		on_confirm.disconnect(connection.callable)
