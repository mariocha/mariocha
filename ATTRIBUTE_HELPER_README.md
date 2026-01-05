# Attribute Helper for SketchUp

A Ruby utility module that simplifies working with entity attributes in SketchUp models.

## Overview

The `AttributeHelper` module provides convenient methods for reading, writing, copying, and managing attributes on SketchUp entities. It includes error handling, default values, and batch operations to make attribute management easier and more robust.

## Features

- **Safe attribute access** with default values
- **Bulk operations** for setting multiple attributes at once
- **Attribute copying** between entities
- **Search functionality** to find entities by attribute values
- **Validation** to ensure entities are valid before operations
- **Error handling** with meaningful feedback
- **Debugging utilities** to print and inspect attributes

## Installation

1. Copy `attribute_helper.rb` to your SketchUp Plugins folder
2. Require it in your Ruby scripts:

```ruby
require 'attribute_helper'
```

## Usage Examples

### Basic Operations

```ruby
# Get an attribute with a default value
door_state = AttributeHelper.get_attribute(entity, 'door_info', 'state', 'closed')

# Set an attribute
AttributeHelper.set_attribute(entity, 'door_info', 'state', 'open')

# Check if attribute exists
if AttributeHelper.has_attribute?(entity, 'door_info', 'state')
  puts "Door has a state"
end
```

### Bulk Operations

```ruby
# Set multiple attributes at once
attributes = {
  'width' => 36.0,
  'height' => 80.0,
  'material' => 'wood',
  'color' => 'oak'
}
AttributeHelper.set_attributes(entity, 'door_properties', attributes)

# Get all attributes from an entity
all_attrs = AttributeHelper.get_all_attributes(entity)
all_attrs.each do |dict_name, attrs|
  puts "Dictionary: #{dict_name}"
  attrs.each { |key, value| puts "  #{key} = #{value}" }
end
```

### Copying Attributes

```ruby
# Copy all attributes from one entity to another
AttributeHelper.copy_attributes(source_door, target_door)

# Copy a specific dictionary
AttributeHelper.copy_attributes(source_door, target_door, 'door_info')
```

### Searching

```ruby
# Find all entities with a specific attribute value
model = Sketchup.active_model
open_doors = AttributeHelper.find_by_attribute(
  model.active_entities,
  'door_info',
  'state',
  'open'
)
puts "Found #{open_doors.length} open doors"
```

### Deleting Attributes

```ruby
# Delete a specific attribute
AttributeHelper.delete_attribute(entity, 'door_info', 'temp_value')

# Delete an entire dictionary
AttributeHelper.delete_attribute(entity, 'door_info')
```

### Debugging

```ruby
# Print all attributes for debugging
AttributeHelper.print_attributes(entity)

# Print specific dictionary
AttributeHelper.print_attributes(entity, 'door_info')
```

## Use Cases

### Door Animation State Management

```ruby
# Track door state for animation
def toggle_door(door_entity)
  current_state = AttributeHelper.get_attribute(door_entity, 'anim', 'open', false)
  new_state = !current_state
  AttributeHelper.set_attribute(door_entity, 'anim', 'open', new_state)
  new_state
end
```

### Component Configuration

```ruby
# Store and retrieve component configuration
config = {
  'type' => 'cabinet',
  'width' => 24.0,
  'depth' => 18.0,
  'height' => 30.0,
  'handle_position' => 'right',
  'material' => 'oak'
}
AttributeHelper.set_attributes(component, 'config', config)
```

### Batch Processing

```ruby
# Update all doors in a model
model = Sketchup.active_model
model.start_operation('Update Doors', true)

doors = AttributeHelper.find_by_attribute(
  model.active_entities,
  'type',
  'component',
  'door'
)

doors.each do |door|
  AttributeHelper.set_attribute(door, 'updated', 'timestamp', Time.now.to_i)
  AttributeHelper.set_attribute(door, 'updated', 'version', '2.0')
end

model.commit_operation
```

## Method Reference

### `get_attribute(entity, dict_name, key, default = nil)`
Safely retrieves an attribute value with an optional default.

### `set_attribute(entity, dict_name, key, value)`
Sets an attribute value with validation and error handling.

### `copy_attributes(source, target, dict_name = nil)`
Copies attributes from one entity to another.

### `delete_attribute(entity, dict_name, key = nil)`
Deletes a specific attribute or entire dictionary.

### `get_all_attributes(entity)`
Returns a hash of all attribute dictionaries and their values.

### `has_attribute?(entity, dict_name, key)`
Checks if an entity has a specific attribute.

### `set_attributes(entity, dict_name, attributes)`
Sets multiple attributes from a hash in a single call.

### `find_by_attribute(entities, dict_name, key, value)`
Searches for entities with a specific attribute value.

### `print_attributes(entity, dict_name = nil)`
Prints attributes to the console for debugging.

## Error Handling

All methods include error handling and will:
- Return `false` for failed operations (instead of raising exceptions)
- Print error messages to help with debugging
- Validate entities before attempting operations
- Handle nil or invalid parameters gracefully

## Compatibility

- SketchUp 2017 and later
- Compatible with both Windows and macOS

## License

This utility is provided as-is for use in SketchUp plugin development.

## Author

mariocha - https://www.simplegraf.org

## Related Tools

For more SketchUp utilities and plugins, visit https://github.com/mariocha
