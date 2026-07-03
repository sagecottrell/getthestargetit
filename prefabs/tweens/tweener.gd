# Save this script as TweenComponent.gd
extends Node
class_name TweenComponent

var active_tween: Tween
@export var duration: float
@export var trans_type: Tween.TransitionType
@export var ease_type: Tween.EaseType
@export var final_value: Variant
@export var property: String

## tween relative to starting position

enum TweenRelative {
	## tween absolute values
	Absolute,
	## tween values relative to the value at _ready() time
	RelativeToInit,
	## tween values relative to the value at animate() time
	RelativeToStart,
}

@export var relative: TweenRelative = TweenRelative.Absolute

var parent: Node3D
var ready_value: Variant = null

var t_duration: float

signal complete()

func _ready():
	parent = get_parent()
	ready_value = parent.get_indexed(property)

func animate():
	animate_property(property, final_value, duration, trans_type, ease_type)

func stop_and_reset():
	if active_tween and active_tween.is_running():
		active_tween.stop()
		
func pause():
	if active_tween and active_tween.is_running():
		active_tween.pause()
		
func resume():
	if active_tween and active_tween.is_running():
		active_tween.play()

## Animates a target node's property smoothly
func animate_property(s_property: String, s_final_value: Variant, s_duration: float, s_trans_type := Tween.TRANS_LINEAR, s_ease_type := Tween.EASE_IN_OUT):
	# Safely kill any running tween on this component to avoid overlapping conflicts
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# Create a fresh tween bound to this node's lifecycle
	active_tween = create_tween()
	
	# Configure easing and transition styles
	active_tween.set_trans(s_trans_type)
	active_tween.set_ease(s_ease_type)
	
	# Execute the animation
	t_duration = s_duration
	
	if relative == TweenRelative.RelativeToInit:
		s_final_value += ready_value
	elif relative == TweenRelative.RelativeToStart:
		s_final_value += parent.get_indexed(s_property)
	
	active_tween.tween_property(get_parent(), s_property, s_final_value, duration)
	active_tween.finished.connect(complete.emit)

func instant_finish():
	if active_tween and active_tween.is_running():
		active_tween.pause()
		active_tween.custom_step(t_duration)
	
