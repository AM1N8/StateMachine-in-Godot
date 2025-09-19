class_name JumpState
extends BaseState

var is_rising: bool = true

func _init():
	animation_name = "jump"

func enter(previous_state_path: String, data := {}):
	super(previous_state_path, data)
	character.jump()
	character.consume_jump_buffer()
	is_rising = true

func physics_update(delta: float):
	character.apply_movement(delta, 0.8)  # Reduced air control
	
	# Variable jump height
	if character.jump_just_released and character.velocity.y < 0:
		character.velocity.y *= 0.5
	
	# Check if we're still rising
	if character.velocity.y >= 0:
		is_rising = false
		state_machine.change_state("FallState")
	
	# Land
	if character.is_on_floor():
		if character.get_input_strength() > 0.1:
			state_machine.change_state("RunState")
		else:
			state_machine.change_state("IdleState")
