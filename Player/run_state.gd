class_name RunState
extends BaseState

func _init():
	animation_name = "run"

func physics_update(delta: float):
	character.apply_movement(delta)
	
	# Check for state transitions
	if not character.is_on_floor():
		state_machine.change_state("FallState")
	elif character.has_jump_buffer() and character.can_jump():
		state_machine.change_state("JumpState")
	elif character.get_input_strength() <= 0.1:
		state_machine.change_state("IdleState")
