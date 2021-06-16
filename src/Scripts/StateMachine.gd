extends KinematicBody2D

var state = 0
var previous_state = null
var states = {}

onready var parent = get_parent()

func _physics_process(delta):
	if state != null:
		_state_logic(delta)
		var transition = _get_transition()
		if transition != null:
			set_state(transition)

func _input(event):
	_input_logic(event)
	var transition = _get_transition()
	if transition != null:
		set_state(transition)
	
func _input_logic(_event):
	pass

func _state_logic(_delta):
	pass
	
func _get_transition():
	return null
	
func _enter_state(_new_state, _old_state):
	pass
	
func _exit_state(_old_state, _new_state):
	pass

func set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)
		
func add_state(state_name):
	states[state_name] = states.size()

func get_state_by_id(id):
	var _state
	for key in states.keys():
		if id == states[key]:
			_state = key
			break
	return _state
