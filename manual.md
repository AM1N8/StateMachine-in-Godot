# Godot State Machine System Documentation

## Overview

This state machine system provides a robust, extensible framework for managing character behavior in Godot 4. It follows the State Pattern design principle, allowing for clean separation of different character states (idle, running, jumping, etc.) while maintaining smooth transitions and consistent behavior.

The system is designed specifically for 2D platformer characters but can be adapted for other game types.

## Architecture

### Core Components

The system consists of four main components:

1. **StateMachine** - Central coordinator that manages state transitions
2. **BaseState** - Abstract base class for all character states
3. **CharacterController** - Character physics and input handling
4. **Concrete States** - Specific implementations (IdleState, RunState, JumpState)

### Design Patterns Used

- **State Pattern**: Each behavior is encapsulated in its own state class
- **Template Method**: BaseState provides common structure, concrete states implement specifics
- **Observer Pattern**: StateMachine emits signals when states change

## Class Reference

### StateMachine

The central coordinator that manages state transitions and maintains the current active state.

#### Properties

- `current_state: BaseState` - Currently active state
- `states: Dictionary` - Registry of all available states
- `character: CharacterController` - Reference to the character being controlled

#### Signals

- `state_changed(new_state_name: String)` - Emitted when transitioning to a new state

#### Methods

##### `change_state(new_state_name: String, data: Dictionary = {})`
Transitions to a new state by name.

**Parameters:**
- `new_state_name`: Name of the target state (must match the node name)
- `data`: Optional dictionary to pass data between states

**Example:**
```gdscript
state_machine.change_state("JumpState", {"jump_power": 1.2})
```

##### `get_state(state_name: String) -> BaseState`
Returns a reference to a specific state.

##### `has_state(state_name: String) -> bool`
Checks if a state exists in the registry.

##### `get_current_state_name() -> String`
Returns the name of the currently active state.

#### Initialization Process

1. Waits for all child nodes to be ready
2. Registers all BaseState children automatically
3. Links each state to the character and state machine
4. Activates the first available state

---

### BaseState

Abstract base class that defines the interface and common behavior for all character states.

#### Properties

- `can_move: bool = true` - Whether the character can move in this state
- `animation_name: String = ""` - Animation to play when entering this state
- `character: CharacterController` - Reference to the character (set automatically)
- `state_machine: StateMachine` - Reference to the state machine (set automatically)

#### Virtual Methods

##### `enter(previous_state_path: String, data := {})`
Called when transitioning into this state.

**Default behavior:**
- Plays the specified animation if `animation_name` is set
- Enables physics processing

**Parameters:**
- `previous_state_path`: Name of the previous state
- `data`: Optional data passed from the previous state

##### `exit()`
Called when transitioning out of this state.

**Default behavior:**
- Disables physics processing

##### `update(delta: float)`
Called every frame during `_process()`.

##### `physics_update(delta: float)`
Called every physics frame during `_physics_process()`.

##### `handle_input(event: InputEvent)`
Called for input events during `_input()`.

#### Implementation Notes

- Physics processing is automatically managed (enabled on enter, disabled on exit)
- States should call `super()` when overriding `enter()` and `exit()`

---

### CharacterController

Handles character physics, input processing, and provides utility methods for states.

#### Movement Properties

- `max_speed: float = 300.0` - Maximum horizontal movement speed
- `acceleration: float = 1500.0` - Rate of speed increase
- `friction: float = 1200.0` - Ground friction when not moving
- `air_resistance: float = 200.0` - Air resistance when airborne

#### Jump Properties

- `jump_velocity: float = -400.0` - Initial jump velocity
- `max_jump_time: float = 0.3` - Maximum variable jump duration
- `coyote_time: float = 0.1` - Grace period for jumping after leaving ground
- `jump_buffer_time: float = 0.2` - Input buffer window for jump timing

#### Physics Properties

- `gravity_scale: float = 1.0` - Gravity multiplier

#### Input Properties

- `move_left_action: String = "ui_left"` - Left movement input action
- `move_right_action: String = "ui_right"` - Right movement input action
- `jump_action: String = "ui_accept"` - Jump input action

#### Key Methods

##### `apply_movement(delta: float, speed_multiplier: float = 1.0)`
Applies horizontal movement with acceleration and friction.

**Parameters:**
- `delta`: Frame time delta
- `speed_multiplier`: Modifier for reduced air control or special states

##### `jump()`
Executes a jump by setting vertical velocity.

##### `can_jump() -> bool`
Returns true if the character can currently jump (on ground or within coyote time).

##### `has_jump_buffer() -> bool`
Returns true if there's a pending jump input within the buffer time.

##### `consume_jump_buffer()`
Clears the jump buffer (call after processing a jump).

##### `get_input_strength() -> float`
Returns the absolute value of horizontal input (0.0 to 1.0).

##### `play_animation(animation_name: String)`
Plays the specified animation safely with error checking.

#### Input State Properties

- `input_direction: float` - Current horizontal input (-1.0 to 1.0)
- `jump_pressed: bool` - Current frame jump button state
- `jump_just_pressed: bool` - True only on the frame jump was pressed
- `jump_just_released: bool` - True only on the frame jump was released
- `facing_direction: int` - Current facing direction (1 for right, -1 for left)

---

## State Implementations

### IdleState

The default resting state when the character is on the ground with no input.

**Animation:** "idle"

**Transitions:**
- To `FallState` when not on floor
- To `JumpState` when jump buffer is active and can jump
- To `RunState` when horizontal input is detected

**Behavior:**
- Applies normal movement (allows friction to stop the character)

### RunState

Active movement state when the character is running on the ground.

**Animation:** "run"

**Transitions:**
- To `FallState` when not on floor
- To `JumpState` when jump buffer is active and can jump
- To `IdleState` when input strength drops below 0.1

**Behavior:**
- Applies normal movement with full control

### JumpState

Active during the rising portion of a jump.

**Animation:** "jump"

**State Variables:**
- `is_rising: bool` - Tracks if character is still moving upward

**Transitions:**
- To `FallState` when vertical velocity becomes non-negative
- To `RunState` when landing with horizontal input
- To `IdleState` when landing without input

**Behavior:**
- Executes jump on enter
- Consumes jump buffer
- Applies movement with 0.8 speed multiplier (reduced air control)
- Supports variable jump height (cuts velocity when jump released early)

## Usage Guide

### Basic Setup

1. **Scene Structure:**
```
Player (CharacterBody2D + CharacterController script)
├── Sprite2D
├── CollisionShape2D
├── AnimationPlayer
└── StateMachine (StateMachine script)
    ├── IdleState (IdleState script)
    ├── RunState (RunState script)
    └── JumpState (JumpState script)
```

2. **Configure Input Map:**
   - Set up input actions for movement and jump
   - Update action names in CharacterController if needed

3. **Set Animation Names:**
   - Ensure AnimationPlayer has animations: "idle", "run", "jump"
   - Names must match the `animation_name` in each state

### Creating Custom States

To create a new state:

```gdscript
class_name MyCustomState
extends BaseState

func _init():
    animation_name = "my_animation"

func enter(previous_state_path: String, data := {}):
    super(previous_state_path, data)
    # Custom enter logic here

func physics_update(delta: float):
    # State-specific behavior
    character.apply_movement(delta)
    
    # State transition logic
    if some_condition:
        state_machine.change_state("SomeOtherState")
```

### Adding States Dynamically

```gdscript
# Add a new state instance to the state machine
var wall_slide_state = WallSlideState.new()
wall_slide_state.name = "WallSlideState"
state_machine.add_child(wall_slide_state)
```

### State Communication

Pass data between states:

```gdscript
# From any state
state_machine.change_state("SpecialState", {
    "damage_amount": 50,
    "knockback_direction": Vector2(1, -0.5)
})

# In the receiving state's enter() method
func enter(previous_state_path: String, data := {}):
    super(previous_state_path, data)
    if data.has("damage_amount"):
        take_damage(data.damage_amount)
```

### Listening to State Changes

```gdscript
# Connect to the state machine's signal
state_machine.state_changed.connect(_on_state_changed)

func _on_state_changed(new_state_name: String):
    print("Character entered: ", new_state_name)
    # Update UI, trigger effects, etc.
```

## Best Practices

### State Design

1. **Single Responsibility:** Each state should handle one distinct behavior
2. **Clear Transitions:** Make state transition conditions explicit and easy to understand
3. **Consistent Interface:** Always call `super()` in overridden methods
4. **State Independence:** Avoid states directly calling methods on other states

### Performance Considerations

1. **Physics Processing:** BaseState automatically manages physics processing - don't override unnecessarily
2. **Animation Checks:** Use CharacterController's animation helpers rather than direct AnimationPlayer access
3. **Input Buffering:** Leverage the built-in jump buffer system for responsive controls

### Debugging

1. **State Monitoring:** Connect to `state_changed` signal to log transitions
2. **Visual Feedback:** Use different colored debug draws for different states
3. **Condition Checking:** Add print statements in transition conditions during development

### Extensibility

1. **Additional Fall State:** The system references "FallState" which isn't implemented - add it for complete aerial movement
2. **State Data:** Use the data parameter in `change_state()` for complex state communication
3. **State Stacks:** Consider implementing state stacking for temporary states (like being stunned)

## Common Patterns

### Conditional Transitions
```gdscript
func physics_update(delta: float):
    # Always apply base behavior first
    character.apply_movement(delta)
    
    # Check transitions in priority order
    if critical_condition:
        state_machine.change_state("CriticalState")
    elif important_condition:
        state_machine.change_state("ImportantState")
    elif normal_condition:
        state_machine.change_state("NormalState")
```

### Temporary State Effects
```gdscript
# In a state that should automatically exit after time
var state_timer: float = 0.0

func enter(previous_state_path: String, data := {}):
    super(previous_state_path, data)
    state_timer = data.get("duration", 1.0)

func physics_update(delta: float):
    state_timer -= delta
    if state_timer <= 0:
        state_machine.change_state("IdleState")
```

This state machine system provides a solid foundation for character controllers in Godot 4, with room for expansion and customization based on your specific game needs.