# Godot State Machine System

A robust and extensible finite state machine implementation for 2D character controllers in Godot 4.

## Features

- **Clean Architecture**: State Pattern implementation with automatic state registration
- **Responsive Controls**: Built-in jump buffering, coyote time, and variable jump height
- **Animation Integration**: Seamless AnimationPlayer integration with automatic state-based playback
- **Flexible Input**: Configurable input actions with strength-based transitions
- **Signal-Based**: State change notifications for UI updates and game logic

## Quick Start

1. **Scene Setup**:
```
Player (CharacterBody2D + CharacterController)
├── Sprite2D
├── CollisionShape2D  
├── AnimationPlayer
└── StateMachine
    ├── IdleState
    ├── RunState
    └── JumpState
```

2. **Configure Parameters**: Adjust movement, jump, and physics settings in CharacterController

3. **Setup Animations**: Create "idle", "run", and "jump" animations in AnimationPlayer

4. **Input Map**: Configure input actions (default: arrow keys + space)

## Creating Custom States

```gdscript
class_name MyState
extends BaseState

func _init():
    animation_name = "my_animation"

func physics_update(delta: float):
    character.apply_movement(delta)
    
    if some_condition:
        state_machine.change_state("AnotherState")
```

## Core Classes

- **StateMachine**: Manages state transitions and coordinates between states
- **BaseState**: Abstract base class for all character states
- **CharacterController**: Handles physics, input, and provides utility methods
- **State Implementations**: IdleState, RunState, JumpState (FallState referenced but not included)

## Usage Example

```gdscript
# Transition with data
state_machine.change_state("JumpState", {"power_multiplier": 1.5})

# Listen for state changes
state_machine.state_changed.connect(_on_state_changed)
```

## Requirements

- Godot 4.x
- Input actions: `ui_left`, `ui_right`, `ui_accept` (configurable)

---

Perfect for platformer games, RPGs, or any character-based game needing organized behavior management.
