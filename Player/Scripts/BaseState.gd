class_name BaseState
extends Node

@export var can_move: bool = true
@export var animation_name: String = ""

var character: CharacterController
var state_machine: StateMachine

func _ready():
	# Connect to parent nodes
	set_physics_process(false)

func enter(_previous_state_path: String, _data := {}):
	if animation_name != "":
		character.play_animation(animation_name)
	
	set_physics_process(true)

func exit():
	set_physics_process(false)

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass

func handle_input(_event: InputEvent):
	pass

func _physics_process(delta):
	physics_update(delta)
