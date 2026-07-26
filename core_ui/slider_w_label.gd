@tool
extends VBoxContainer

signal on_value_change(value: float)

@export var Name: String = "volume":
	set(v):
		%Name.text = v
		Name = v
		
@export var Max: float = 100:
	set(v):
		%Slider.max_value = v
		Max = v
		
@export var Min: float = 0:
	set(v):
		%Slider.min_value = v
		Max = v

@export var Value: float = 100:
	set(v):
		%Slider.value = v
		Value = v
		_format_value()

@export var Format: String = "{0}%":
	set(v):
		Format = v
		_format_value()

func _on_slider_value_changed(value: float) -> void:
	on_value_change.emit(value)
	Value = value

func _format_value():
	%Value.text = Format.format([Value])
	
