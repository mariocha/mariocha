# Attribute Helper for SketchUp
# A utility module for managing entity attributes in SketchUp models
#
# Author: mariocha
# Description: Simplifies reading, writing, and managing attributes on SketchUp entities

module AttributeHelper
  
  # Get an attribute value with a default fallback
  # @param entity [Sketchup::Entity] The entity to read from
  # @param dict_name [String] The attribute dictionary name
  # @param key [String] The attribute key
  # @param default [Object] Default value if attribute doesn't exist
  # @return [Object] The attribute value or default
  def self.get_attribute(entity, dict_name, key, default = nil)
    return default unless entity && entity.valid?
    value = entity.get_attribute(dict_name, key)
    value.nil? ? default : value
  end
  
  # Set an attribute value
  # @param entity [Sketchup::Entity] The entity to write to
  # @param dict_name [String] The attribute dictionary name
  # @param key [String] The attribute key
  # @param value [Object] The value to set
  # @return [Boolean] true if successful, false otherwise
  def self.set_attribute(entity, dict_name, key, value)
    return false unless entity && entity.valid?
    entity.set_attribute(dict_name, key, value)
    true
  rescue => e
    puts "Error setting attribute: #{e.message}"
    false
  end
  
  # Copy all attributes from one entity to another
  # @param source [Sketchup::Entity] The source entity
  # @param target [Sketchup::Entity] The target entity
  # @param dict_name [String, nil] Specific dictionary to copy, or nil for all
  # @return [Boolean] true if successful
  def self.copy_attributes(source, target, dict_name = nil)
    return false unless source && source.valid? && target && target.valid?
    
    if dict_name
      # Copy specific dictionary
      dict = source.attribute_dictionary(dict_name)
      return true unless dict # No dictionary to copy
      
      dict.each_pair do |key, value|
        target.set_attribute(dict_name, key, value)
      end
    else
      # Copy all dictionaries
      source.attribute_dictionaries&.each do |dict|
        dict.each_pair do |key, value|
          target.set_attribute(dict.name, key, value)
        end
      end
    end
    
    true
  rescue => e
    puts "Error copying attributes: #{e.message}"
    false
  end
  
  # Delete an attribute
  # @param entity [Sketchup::Entity] The entity
  # @param dict_name [String] The attribute dictionary name
  # @param key [String, nil] The attribute key, or nil to delete entire dictionary
  # @return [Boolean] true if successful
  def self.delete_attribute(entity, dict_name, key = nil)
    return false unless entity && entity.valid?
    
    if key
      entity.delete_attribute(dict_name, key)
    else
      dict = entity.attribute_dictionary(dict_name)
      dict.delete if dict
    end
    
    true
  rescue => e
    puts "Error deleting attribute: #{e.message}"
    false
  end
  
  # Get all attribute dictionaries for an entity
  # @param entity [Sketchup::Entity] The entity
  # @return [Hash] Hash of dictionary names to their key-value pairs
  def self.get_all_attributes(entity)
    return {} unless entity && entity.valid?
    
    result = {}
    entity.attribute_dictionaries&.each do |dict|
      result[dict.name] = {}
      dict.each_pair do |key, value|
        result[dict.name][key] = value
      end
    end
    
    result
  end
  
  # Check if an entity has a specific attribute
  # @param entity [Sketchup::Entity] The entity
  # @param dict_name [String] The attribute dictionary name
  # @param key [String] The attribute key
  # @return [Boolean] true if attribute exists
  def self.has_attribute?(entity, dict_name, key)
    return false unless entity && entity.valid?
    dict = entity.attribute_dictionary(dict_name)
    return false unless dict
    dict.keys.include?(key)
  end
  
  # Bulk set attributes from a hash
  # @param entity [Sketchup::Entity] The entity
  # @param dict_name [String] The attribute dictionary name
  # @param attributes [Hash] Hash of key-value pairs to set
  # @return [Boolean] true if successful
  def self.set_attributes(entity, dict_name, attributes)
    return false unless entity && entity.valid?
    return false unless attributes.is_a?(Hash)
    
    attributes.each do |key, value|
      entity.set_attribute(dict_name, key, value)
    end
    
    true
  rescue => e
    puts "Error setting attributes: #{e.message}"
    false
  end
  
  # Search entities by attribute value
  # @param entities [Sketchup::Entities] The entities collection to search
  # @param dict_name [String] The attribute dictionary name
  # @param key [String] The attribute key
  # @param value [Object] The value to match
  # @return [Array] Array of matching entities
  def self.find_by_attribute(entities, dict_name, key, value)
    return [] unless entities
    
    results = []
    entities.each do |entity|
      next unless entity.valid?
      attr_value = entity.get_attribute(dict_name, key)
      results << entity if attr_value == value
    end
    
    results
  end
  
  # Print all attributes for debugging
  # @param entity [Sketchup::Entity] The entity
  # @param dict_name [String, nil] Specific dictionary or nil for all
  def self.print_attributes(entity, dict_name = nil)
    return unless entity && entity.valid?
    
    puts "Attributes for #{entity.class}:"
    
    if dict_name
      dict = entity.attribute_dictionary(dict_name)
      if dict
        puts "  Dictionary: #{dict_name}"
        dict.each_pair do |key, value|
          puts "    #{key} => #{value.inspect}"
        end
      else
        puts "  No dictionary named '#{dict_name}'"
      end
    else
      dicts = entity.attribute_dictionaries
      if dicts
        dicts.each do |dict|
          puts "  Dictionary: #{dict.name}"
          dict.each_pair do |key, value|
            puts "    #{key} => #{value.inspect}"
          end
        end
      else
        puts "  No attribute dictionaries"
      end
    end
  end
  
end
