# Save this script as TweenComponent.gd
@tool
class_name TweenComponent
extends Node

enum TweenRelative {
	## tween absolute values
	Absolute,
	## tween values relative to the value at _ready() time
	RelativeToInit,
	## tween values relative to the value at animate() time
	RelativeToStart,
}

var active_tween: Tween
@export var start_active: bool = false
@export var duration: float = 1
@export var trans_type: Tween.TransitionType
@export var ease_type: Tween.EaseType

@export var final_value: Variant = 0.0
		
## a property string, can have nested selectors (like `position:x`)
@export var property: String:
	set(v):
		property = v
		update_configuration_warnings()
	get:
		return property
## tween relative to starting position
@export var relative: TweenRelative = TweenRelative.Absolute:
	set(v):
		relative = v
		match v:
			TweenRelative.RelativeToInit:
				if is_node_ready():
					ready_value = parent.get_indexed(property)
	get:
		return relative
## how many loops. 1 is no loops, just animates once
@export var loops: int = 1
@export var reset_init_on_start: bool = false

var parent: Node3D
var ready_value: Variant = null

var t_duration: float
var t_loops: int
var in_tweentree: bool

var init_dirty := true

signal on_completed()
signal on_paused()
signal on_resumed()
signal on_stopped()


func _ready():
	get_tweened_parent()
	t_loops = loops
	
	if start_active:
		animate()

func animate():
	animate_property(property, final_value, duration, trans_type, ease_type)

func get_tweened_parent():
	var p = get_parent()
	while p is TweenTree:
		in_tweentree = true
		p = p.get_parent()
	if p:
		parent = p
		ready_value = parent.get_indexed(property)
	init_dirty = false

func stop_and_reset():
	stop()
	reset()

func reset():
	t_loops = loops
	parent.set_indexed(property, ready_value)
		
func pause():
	if active_tween and active_tween.is_running():
		active_tween.pause()
		on_paused.emit()
		
func resume():
	if active_tween and active_tween.is_running():
		active_tween.play()
		on_resumed.emit()

func stop():
	if active_tween and active_tween.is_running():
		active_tween.stop()
		on_stopped.emit()

func reinit():
	if init_dirty:
		get_tweened_parent()

## Animates a target node's property smoothly
func animate_property(s_property: String, s_final_value: Variant, s_duration: float, s_trans_type := Tween.TRANS_LINEAR, s_ease_type := Tween.EASE_IN_OUT):
	# Safely kill any running tween on this component to avoid overlapping conflicts
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# Create a fresh tween bound to this node's lifecycle
	active_tween = create_tween()
	active_tween.set_loops(t_loops)
	
	# Configure easing and transition styles
	active_tween.set_trans(s_trans_type)
	active_tween.set_ease(s_ease_type)
	
	# Execute the animation
	t_duration = s_duration
	var cval = parent.get_indexed(s_property)
	var relative_value = 0
	
	if relative == TweenRelative.RelativeToInit and reset_init_on_start:
		parent.set_indexed(s_property, ready_value)
		cval = ready_value
	
	match relative:
		TweenRelative.RelativeToInit:
			relative_value = ready_value + s_final_value - cval
		TweenRelative.Absolute:
			relative_value = s_final_value - cval
		TweenRelative.RelativeToStart:
			relative_value = s_final_value
			
	var tweener = active_tween.tween_property(parent, s_property, relative_value, duration).as_relative()
	if Engine.is_editor_hint() and not in_tweentree:
		tweener.finished.connect(reset)
	
	active_tween.finished.connect(_completed)

func _completed():
	active_tween = null
	on_completed.emit()

func instant_finish():
	if active_tween and active_tween.is_running():
		active_tween.pause()
		active_tween.custom_step(t_duration)
		_completed()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_EDITOR_PRE_SAVE:
			# Temporarily reset changes before the editor writes the file
			if active_tween and active_tween.is_running():
				stop_and_reset()
			init_dirty = true
		NOTIFICATION_PATH_RENAMED:
			get_tweened_parent()
			init_dirty = true
	

func _editor_start_loop_forever():
	if Engine.is_editor_hint():
		t_loops = 0
		animate()

# Override this virtual function to pass error messages to the editor
func _get_configuration_warnings():
	var warnings = []
	if parent == null:
		warnings.append("parent is null??")
		return warnings
	# Condition to trigger the editor error
	if property == null or len(property) == 0:
		warnings.append("must set a property!")
	elif parent.get_indexed(property) == null:
		warnings.append("parent node does not contain the property '%s'" % [property])
	return warnings

@export_tool_button("Preview", "Callable") var preview_action = _editor_start_loop_forever
@export_tool_button("Pause", "Callable") var pause_action = pause
@export_tool_button("Resume", "Callable") var resume_action = resume
@export_tool_button("Stop", "Callable") var stop_action = stop_and_reset
