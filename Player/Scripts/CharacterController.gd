class_name CharacterController
extends CharacterBody2D

@export_group("Movement")
@export var max_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0
@export var air_resistance: float = 200.0

@export_group("Jump")
@export var jump_velocity: float = -400.0
@export var max_jump_time: float = 0.3
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.2

@export_group("Physics")
@export var gravity_scale: float = 1.0

@export_group("Input")
@export var move_left_action: String = "ui_left"
@export var move_right_action: String = "ui_right"
@export var jump_action: String = "ui_accept"

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

##################### Tracking the moves #########################

var input_direction: float = 0.0
var jump_pressed: bool = false
var jump_just_pressed: bool = false
var jump_just_released: bool = false

var facing_direction: int = 1  # 1 for right, -1 for left
var was_on_floor_last_frame: bool = false

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var jump_time: float = 0.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

####################### checking #################################

func _ready():
	if not sprite:
		push_error("CharacterController requires a Sprite2D child named 'Sprite2D'")
	if not animation_player:
		push_error("CharacterController requires an AnimationPlayer child named 'AnimationPlayer'")
	if not state_machine:
		push_error("CharacterController requires a StateMachine child named 'StateMachine'")

###################### main loop ##################################

func _physics_process(delta):
	update_input()
	update_timers(delta)
	apply_gravity(delta)
	move_and_slide()
	update_facing_direction()
	was_on_floor_last_frame = is_on_floor()
	
func update_input():
	var old_jump = jump_pressed
	
	input_direction = Input.get_axis(move_left_action, move_right_action)
	jump_pressed = Input.is_action_pressed(jump_action)
	jump_just_pressed = Input.is_action_just_pressed(jump_action)
	jump_just_released = Input.is_action_just_released(jump_action)
	
	# Jump buffer
	if jump_just_pressed:
		jump_buffer_timer = jump_buffer_time

func update_timers(delta: float):
	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
	
	# Jump buffer
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	
	# Jump time
	if jump_pressed and jump_time < max_jump_time:
		jump_time += delta
	else:
		jump_time = 0.0

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta

func update_facing_direction():
	if input_direction > 0:
		facing_direction = 1
		sprite.scale.x = abs(sprite.scale.x)
	elif input_direction < 0:
		facing_direction = -1
		sprite.scale.x = -abs(sprite.scale.x)

func can_jump() -> bool:
	return coyote_timer > 0.0 or is_on_floor()

func has_jump_buffer() -> bool:
	return jump_buffer_timer > 0.0

func consume_jump_buffer():
	jump_buffer_timer = 0.0

func apply_movement(delta: float, speed_multiplier: float = 1.0):
	var target_velocity = input_direction * max_speed * speed_multiplier
	
	if input_direction != 0:
		# Accelerate
		velocity.x = move_toward(velocity.x, target_velocity, acceleration * delta)
	else:
		# Apply friction or air resistance
		var resistance = friction if is_on_floor() else air_resistance
		velocity.x = move_toward(velocity.x, 0, resistance * delta)

func jump():
	velocity.y = jump_velocity
	jump_time = 0.0

func get_input_strength() -> float:
	return abs(input_direction)

# Animation helper functions
func play_animation(animation_name: String):
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	else:
		push_warning("Animation '%s' not found" % animation_name)

func is_animation_playing(animation_name: String) -> bool:
	return animation_player.current_animation == animation_name and animation_player.is_playing()

func get_current_animation() -> String:
	return animation_player.current_animation
