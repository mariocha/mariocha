# Attribute Helper - Quick Start Guide

## Installation
```ruby
# In your SketchUp plugin loader:
require_relative 'attribute_helper'
```

## 5-Minute Tutorial

### 1. Basic Get/Set
```ruby
# Set an attribute
AttributeHelper.set_attribute(door, 'props', 'state', 'open')

# Get with default fallback
state = AttributeHelper.get_attribute(door, 'props', 'state', 'closed')
```

### 2. Check if Exists
```ruby
if AttributeHelper.has_attribute?(door, 'props', 'state')
  puts "Door has a state"
end
```

### 3. Set Multiple at Once
```ruby
config = {
  'width' => 36.0,
  'height' => 80.0,
  'material' => 'oak'
}
AttributeHelper.set_attributes(door, 'config', config)
```

### 4. Copy Between Entities
```ruby
# Copy all attributes
AttributeHelper.copy_attributes(source_door, new_door)

# Copy just one dictionary
AttributeHelper.copy_attributes(source_door, new_door, 'config')
```

### 5. Find Entities
```ruby
# Find all open doors
open_doors = AttributeHelper.find_by_attribute(
  model.active_entities,
  'props',
  'state',
  'open'
)
puts "Found #{open_doors.length} open doors"
```

### 6. Debug/Inspect
```ruby
# Print all attributes for debugging
AttributeHelper.print_attributes(door)

# Get all as a hash
all_attrs = AttributeHelper.get_all_attributes(door)
```

## Common Patterns

### Toggle Door State
```ruby
def toggle_door(door)
  current = AttributeHelper.get_attribute(door, 'anim', 'open', false)
  AttributeHelper.set_attribute(door, 'anim', 'open', !current)
end
```

### Batch Update
```ruby
doors = AttributeHelper.find_by_attribute(
  model.active_entities, 'type', 'component', 'door'
)

model.start_operation('Update Doors')
doors.each do |door|
  AttributeHelper.set_attribute(door, 'meta', 'updated', Time.now.to_i)
end
model.commit_operation
```

### Configuration Template
```ruby
DOOR_DEFAULTS = {
  'width' => 36.0,
  'height' => 80.0,
  'swing' => 90,
  'material' => 'wood'
}

def configure_door(door, overrides = {})
  config = DOOR_DEFAULTS.merge(overrides)
  AttributeHelper.set_attributes(door, 'config', config)
end
```

## Need More Help?

- Full documentation: [ATTRIBUTE_HELPER_README.md](ATTRIBUTE_HELPER_README.md)
- Implementation details: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
- Run tests: `ruby test_attribute_helper.rb`

## Tips

1. Always use dictionary names consistently (e.g., 'config', 'props', 'anim')
2. Use defaults with `get_attribute` to avoid nil checks
3. Wrap batch operations in start_operation/commit_operation
4. Use `print_attributes` during development to inspect values
5. The module validates entities automatically - no need to check `valid?`
