#!/usr/bin/env ruby
# Test suite for AttributeHelper module
# Run with: ruby test_attribute_helper.rb

require_relative 'attribute_helper'

# Mock SketchUp classes for testing
module Sketchup
  class Entity
    attr_accessor :valid, :attribute_data
    
    def initialize
      @valid = true
      @attribute_data = {}
    end
    
    def valid?
      @valid
    end
    
    def get_attribute(dict_name, key)
      return nil unless @attribute_data[dict_name]
      @attribute_data[dict_name][key]
    end
    
    def set_attribute(dict_name, key, value)
      @attribute_data[dict_name] ||= {}
      @attribute_data[dict_name][key] = value
    end
    
    def delete_attribute(dict_name, key = nil)
      return unless @attribute_data[dict_name]
      if key
        @attribute_data[dict_name].delete(key)
      else
        @attribute_data.delete(dict_name)
      end
    end
    
    def attribute_dictionary(dict_name)
      return nil unless @attribute_data[dict_name]
      MockDict.new(dict_name, @attribute_data[dict_name])
    end
    
    def attribute_dictionaries
      return nil if @attribute_data.empty?
      @attribute_data.map { |name, data| MockDict.new(name, data) }
    end
  end
  
  class MockDict
    attr_reader :name, :data
    
    def initialize(name, data)
      @name = name
      @data = data
    end
    
    def keys
      @data.keys
    end
    
    def each_pair(&block)
      @data.each_pair(&block)
    end
    
    def delete
      @data.clear
    end
  end
end

# Test helper
def assert(condition, message)
  if condition
    puts "✓ #{message}"
    true
  else
    puts "✗ #{message}"
    false
  end
end

def test_get_attribute
  puts "\nTesting get_attribute..."
  entity = Sketchup::Entity.new
  entity.set_attribute('test_dict', 'key1', 'value1')
  
  result = AttributeHelper.get_attribute(entity, 'test_dict', 'key1')
  assert(result == 'value1', "Should return correct value")
  
  result = AttributeHelper.get_attribute(entity, 'test_dict', 'missing_key', 'default')
  assert(result == 'default', "Should return default for missing key")
  
  result = AttributeHelper.get_attribute(nil, 'test_dict', 'key1')
  assert(result.nil?, "Should return nil for nil entity")
end

def test_set_attribute
  puts "\nTesting set_attribute..."
  entity = Sketchup::Entity.new
  
  result = AttributeHelper.set_attribute(entity, 'test_dict', 'key1', 'value1')
  assert(result == true, "Should return true on success")
  
  stored = entity.get_attribute('test_dict', 'key1')
  assert(stored == 'value1', "Should store value correctly")
  
  result = AttributeHelper.set_attribute(nil, 'test_dict', 'key1', 'value1')
  assert(result == false, "Should return false for nil entity")
end

def test_has_attribute
  puts "\nTesting has_attribute?..."
  entity = Sketchup::Entity.new
  entity.set_attribute('test_dict', 'key1', 'value1')
  
  result = AttributeHelper.has_attribute?(entity, 'test_dict', 'key1')
  assert(result == true, "Should return true for existing attribute")
  
  result = AttributeHelper.has_attribute?(entity, 'test_dict', 'missing_key')
  assert(result == false, "Should return false for missing attribute")
  
  result = AttributeHelper.has_attribute?(entity, 'missing_dict', 'key1')
  assert(result == false, "Should return false for missing dictionary")
end

def test_set_attributes
  puts "\nTesting set_attributes..."
  entity = Sketchup::Entity.new
  
  attrs = { 'key1' => 'value1', 'key2' => 'value2', 'key3' => 123 }
  result = AttributeHelper.set_attributes(entity, 'test_dict', attrs)
  assert(result == true, "Should return true on success")
  
  assert(entity.get_attribute('test_dict', 'key1') == 'value1', "Should store first value")
  assert(entity.get_attribute('test_dict', 'key2') == 'value2', "Should store second value")
  assert(entity.get_attribute('test_dict', 'key3') == 123, "Should store numeric value")
end

def test_copy_attributes
  puts "\nTesting copy_attributes..."
  source = Sketchup::Entity.new
  target = Sketchup::Entity.new
  
  source.set_attribute('dict1', 'key1', 'value1')
  source.set_attribute('dict1', 'key2', 'value2')
  source.set_attribute('dict2', 'key3', 'value3')
  
  result = AttributeHelper.copy_attributes(source, target, 'dict1')
  assert(result == true, "Should return true on success")
  
  assert(target.get_attribute('dict1', 'key1') == 'value1', "Should copy first value")
  assert(target.get_attribute('dict1', 'key2') == 'value2', "Should copy second value")
  assert(target.get_attribute('dict2', 'key3').nil?, "Should not copy other dictionaries")
  
  # Test copying all dictionaries
  target2 = Sketchup::Entity.new
  result = AttributeHelper.copy_attributes(source, target2)
  assert(result == true, "Should return true when copying all")
  assert(target2.get_attribute('dict2', 'key3') == 'value3', "Should copy all dictionaries")
end

def test_delete_attribute
  puts "\nTesting delete_attribute..."
  entity = Sketchup::Entity.new
  entity.set_attribute('test_dict', 'key1', 'value1')
  entity.set_attribute('test_dict', 'key2', 'value2')
  
  result = AttributeHelper.delete_attribute(entity, 'test_dict', 'key1')
  assert(result == true, "Should return true on success")
  assert(entity.get_attribute('test_dict', 'key1').nil?, "Should delete specific key")
  assert(entity.get_attribute('test_dict', 'key2') == 'value2', "Should keep other keys")
  
  result = AttributeHelper.delete_attribute(entity, 'test_dict')
  assert(result == true, "Should return true when deleting dictionary")
end

def test_get_all_attributes
  puts "\nTesting get_all_attributes..."
  entity = Sketchup::Entity.new
  entity.set_attribute('dict1', 'key1', 'value1')
  entity.set_attribute('dict1', 'key2', 'value2')
  entity.set_attribute('dict2', 'key3', 'value3')
  
  result = AttributeHelper.get_all_attributes(entity)
  assert(result.is_a?(Hash), "Should return a hash")
  assert(result.keys.sort == ['dict1', 'dict2'], "Should include all dictionaries")
  assert(result['dict1']['key1'] == 'value1', "Should include all values")
  
  empty_entity = Sketchup::Entity.new
  result = AttributeHelper.get_all_attributes(empty_entity)
  assert(result == {}, "Should return empty hash for entity with no attributes")
end

def test_find_by_attribute
  puts "\nTesting find_by_attribute..."
  entities = []
  
  # Create mock entities collection
  3.times do |i|
    entity = Sketchup::Entity.new
    entity.set_attribute('test_dict', 'type', i == 1 ? 'door' : 'wall')
    entity.set_attribute('test_dict', 'id', i)
    entities << entity
  end
  
  # Create a mock entities collection
  class << entities
    alias_method :each, :each
  end
  
  results = AttributeHelper.find_by_attribute(entities, 'test_dict', 'type', 'door')
  assert(results.length == 1, "Should find one matching entity")
  assert(results[0].get_attribute('test_dict', 'id') == 1, "Should find correct entity")
  
  results = AttributeHelper.find_by_attribute(entities, 'test_dict', 'type', 'window')
  assert(results.length == 0, "Should return empty array for no matches")
end

# Run all tests
puts "=" * 50
puts "Running AttributeHelper Tests"
puts "=" * 50

passed = 0
total = 0

[
  :test_get_attribute,
  :test_set_attribute,
  :test_has_attribute,
  :test_set_attributes,
  :test_copy_attributes,
  :test_delete_attribute,
  :test_get_all_attributes,
  :test_find_by_attribute
].each do |test|
  total += 1
  begin
    send(test)
    passed += 1
  rescue => e
    puts "✗ Test #{test} failed with error: #{e.message}"
    puts e.backtrace.first(3)
  end
end

puts "\n" + "=" * 50
puts "Test Results: #{passed}/#{total} test groups passed"
puts "=" * 50

exit(passed == total ? 0 : 1)
