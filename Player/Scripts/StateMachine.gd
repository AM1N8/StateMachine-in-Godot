class_name StateMachine
extends Node

signal state_changed(new_state_name: String)

var current_state: BaseState
var states: Dictionary = {}
var character: CharacterController

func _ready():
	# Initialize after all children are ready
	call_deferred("_initialize")

func _initialize():
	character = get_parent() as CharacterController
	
	# Register all child states
	for child in get_children():
		if child is BaseState:
			states[child.name] = child
			child.character = character
			child.state_machine = self
	
	# pick the first state available 
	if states.size() > 0:
		var first_state = states.values()[0]
		change_state(first_state.name)

func _process(delta):
	if current_state:
		current_state.update(delta)

func _input(event):
	if current_state:
		current_state.handle_input(event)

func change_state(new_state_name: String, data: Dictionary = {}):
	if not states.has(new_state_name):
		push_warning("State '%s' does not exist" % new_state_name)
		return
	
	var new_state = states[new_state_name]
	var previous_state_path = ""
	
	if current_state:
		previous_state_path = current_state.name
		current_state.exit()
	
	current_state = new_state
	current_state.enter(previous_state_path, data)
	
	state_changed.emit(new_state_name)

func get_state(state_name: String) -> BaseState:
	return states.get(state_name, null)

func has_state(state_name: String) -> bool:
	return states.has(state_name)

func get_current_state_name() -> String:
	return current_state.name if current_state else ""
