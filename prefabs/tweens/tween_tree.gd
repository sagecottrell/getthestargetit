@tool
class_name TweenTree
extends Node

signal on_paused()
signal on_resumed()
signal on_completed()
signal on_stopped()

enum ChildChangedBehavior {
	Restart,
	Stop,
	KeepOn,
}

@export var start_active: bool = false
@export var loops: int = 1
@export var children_changed: ChildChangedBehavior = ChildChangedBehavior.Restart

var t_loops: int = 0
var loops_done: int = 0
var children: Array = []
var index = -1
var paused: bool = true
var in_tweentree: bool

func _ready():
	if get_parent() is TweenTree:
		in_tweentree = true
	rediscover_children()
	t_loops = loops
	child_order_changed.connect(_children_changed)
	if start_active:
		animate()

func _children_changed() -> void:
	match children_changed:
		ChildChangedBehavior.Restart:
			stop_and_reset()
			rediscover_children()
			animate()
		ChildChangedBehavior.Stop:
			stop()
			rediscover_children()
		ChildChangedBehavior.KeepOn:
			rediscover_children()
			if index >= children.size():
				stop_and_reset()


func rediscover_children():
	children.clear()
	for child in get_children():
		if child is TweenComponent or child is TweenTree:
			children.append(child)

func reset():
	var c = current()
	if c != null:
		c.on_completed.disconnect(next)
		
	index = -1
	paused = true
	loops_done = 0

func pause():
	if not paused and index >= 0:
		on_paused.emit()
		paused = true

func resume():
	if paused and index >= 0:
		on_resumed.emit()
		paused = false

func stop():
	var c = current()
	if c != null:
		c.stop()
		on_stopped.emit()
		
func stop_and_reset():
	var c = current()
	if c != null:
		c.stop_and_reset()
	reset()

func animate():
	if index >= 0:
		push_error("already animating: %s" % [get_path()])
		return
	next()
	
func next():
	var c = current()
	if c != null:
		c.on_completed.disconnect(next)
	
	index += 1
	if index >= children.size():
		loops_done += 1
		if t_loops > 0 and loops_done >= t_loops:
			on_completed.emit()
			
			if Engine.is_editor_hint() and not in_tweentree:
				reset()
		else:
			index = -1
			next()
	else:
		var child = children[index]
		child.animate()
		child.on_completed.connect(next)

func current() -> TweenComponent:
	if index >= 0:
		return children[index]
	return null

func _editor_start_loop_forever():
	if Engine.is_editor_hint():
		t_loops = 0
		animate()

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		# Temporarily reset changes before the editor writes the file
		if index > -1:
			stop_and_reset()

@export_tool_button("Preview", "Callable") var preview_action = _editor_start_loop_forever
@export_tool_button("Pause", "Callable") var pause_action = pause
@export_tool_button("Resume", "Callable") var resume_action = resume
@export_tool_button("Stop", "Callable") var stop_action = stop_and_reset
