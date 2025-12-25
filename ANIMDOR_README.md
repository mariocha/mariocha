# AnimDor - Progressive Door and Drawer Animation for SketchUp

## Overview

AnimDor is a SketchUp extension that provides smooth, progressive animations for cabinet doors and drawers while maintaining a single undo operation for all changes.

## Key Features

1. **Progressive Animations**: Uses `UI.start_timer` to create smooth, frame-by-frame animations instead of instant transformations
2. **Single Undo Operation**: All animations are grouped under a single undo operation, regardless of how many entities are animated
3. **Proper Animation Tracking**: Uses a `@pending_commits` counter to ensure the operation only commits when all animations complete
4. **Edge Case Handling**: Correctly handles scenarios where no animations are needed (e.g., entities already in desired state)

## Implementation Details

### Architecture

The implementation follows these key principles:

1. **Animation Separation**: Each entity gets its own timer-based animation loop
2. **Incremental Transformations**: Animations are broken into small steps (default: 20 steps at 30ms intervals)
3. **Completion Tracking**: Each animation decrements the `@pending_commits` counter when complete
4. **Deferred Commit**: The undo operation only commits when `@pending_commits` reaches 0

### Configuration

```ruby
ANIMATION_STEPS = 20  # Number of steps for smooth animation
FRAME_DELAY = 0.03    # Delay between frames in seconds (30ms for ~33 fps)
```

Adjust these constants to change animation smoothness and speed:
- **More steps + shorter delay** = smoother but takes longer
- **Fewer steps + longer delay** = faster but choppier

### Main Methods

#### `animate_doors(entities, target_angle, axis)`

Animates an array of door components to a target rotation angle.

**Parameters:**
- `entities`: Array of `Sketchup::ComponentInstance` objects (doors)
- `target_angle`: Target rotation angle in degrees
- `axis`: Rotation axis (default: Z_AXIS)

**Example:**
```ruby
doors = model.selection.to_a
AnimDor.animate_doors(doors, 90, Z_AXIS)  # Open doors 90 degrees
```

#### `open_doors(doors)`

Helper method to animate doors to open position (90 degrees).

**Example:**
```ruby
AnimDor.open_doors(model.selection.to_a)
```

#### `close_doors(doors)`

Helper method to animate doors to closed position (-90 degrees).

**Example:**
```ruby
AnimDor.close_doors(model.selection.to_a)
```

#### `pull_drawers(drawers, distance)`

Animates drawers by translating them along their local X axis.

**Parameters:**
- `drawers`: Array of `Sketchup::ComponentInstance` objects (drawers)
- `distance`: Distance to pull out in current units (default: 12.0)

**Example:**
```ruby
drawers = model.selection.to_a
AnimDor.pull_drawers(drawers, 12.0)
```

### How It Works

#### 1. Operation Start
When animation begins, a single undo operation starts:
```ruby
model.start_operation('Animate Doors', true)
@operation_started = true
```

#### 2. Animation Tracking
The system tracks how many animations are running:
```ruby
@pending_commits = entities_to_animate.length
```

#### 3. Progressive Animation Loop
Each entity gets a timer that runs at regular intervals:
```ruby
timer_id = UI.start_timer(FRAME_DELAY, true) do
  if current_step < ANIMATION_STEPS && entity.valid?
    # Perform incremental transformation
    rotation = Geom::Transformation.rotation(origin, axis, angle_per_step)
    entity.transform!(rotation)
    current_step += 1
  else
    # Animation complete
    UI.stop_timer(timer_id)
    animation_complete(entity)
  end
end
```

#### 4. Completion and Commit
When each animation finishes, it decrements the counter:
```ruby
def animation_complete(entity)
  @pending_commits -= 1
  if @pending_commits <= 0
    commit_all_animations  # Only commits when all are done
  end
end
```

### Edge Cases Handled

1. **No Animations Needed**: If all entities are already in the target state, no operation is started and nothing is committed
2. **Invalid Entities**: Entity validity is checked during animation to handle deleted/invalid entities gracefully
3. **Multiple Simultaneous Calls**: State tracking ensures operations don't interfere with each other

## Usage in SketchUp

### As a Plugin

1. Copy `animdor.rb` to your SketchUp Plugins folder
2. Load it in SketchUp's Ruby Console or from another plugin

### From Ruby Console

```ruby
# Load the module
load 'animdor.rb'

# Select some door components in SketchUp
model = Sketchup.active_model
doors = model.selection.to_a

# Animate them
AnimDor.open_doors(doors)

# To close them
AnimDor.close_doors(doors)

# For drawers
drawers = model.selection.to_a
AnimDor.pull_drawers(drawers, 12.0)
```

### Integration with UI

You can create menu items or toolbar buttons that call these methods:

```ruby
# Add menu item
UI.menu('Plugins').add_item('Open Doors') {
  model = Sketchup.active_model
  selection = model.selection.to_a
  AnimDor.open_doors(selection)
}
```

## Testing

The `test_animdor.rb` file provides comprehensive tests for all functionality:

```bash
ruby test_animdor.rb
```

Tests cover:
- Single entity animation
- Multiple entity animations
- Edge case: no animations needed
- Drawer animations
- State reset functionality

## Troubleshooting

### Animations Not Smooth

Try adjusting the configuration:
```ruby
AnimDor::ANIMATION_STEPS = 30  # More steps
AnimDor::FRAME_DELAY = 0.02    # Faster frame rate
```

### Undo Issues

If undo isn't working properly, reset the state:
```ruby
AnimDor.reset
```

### Performance Issues

If animating many entities causes slowdown:
1. Reduce `ANIMATION_STEPS` (e.g., to 10)
2. Increase `FRAME_DELAY` (e.g., to 0.05)
3. Animate fewer entities at once

## Technical Notes

- The implementation uses `transform!` for in-place transformations, which is efficient
- Timers are stopped when animations complete to prevent memory leaks
- The module uses class-level instance variables for state management
- All angles are converted to radians internally for compatibility with both SketchUp and standard Ruby

## License

This implementation is provided as-is for use in SketchUp extensions.
