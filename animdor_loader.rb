# animdor_loader.rb - SketchUp Plugin Loader for AnimDor
#
# This file demonstrates how to load AnimDor as a SketchUp extension
# Place this file in the SketchUp/Plugins directory

require 'sketchup.rb'
require 'extensions.rb'

module MarioChaCabinets
  module AnimDorExtension
    
    # Extension information
    EXTENSION_NAME = 'AnimDor - Progressive Cabinet Animations'
    EXTENSION_VERSION = '1.0.0'
    EXTENSION_DESCRIPTION = 'Animate cabinet doors and drawers with smooth, progressive animations'
    EXTENSION_CREATOR = 'MarioCha'
    
    # Create the extension
    extension = SketchupExtension.new(EXTENSION_NAME, 'animdor.rb')
    extension.version = EXTENSION_VERSION
    extension.description = EXTENSION_DESCRIPTION
    extension.creator = EXTENSION_CREATOR
    extension.copyright = "© 2025 #{EXTENSION_CREATOR}"
    
    # Register the extension with SketchUp
    Sketchup.register_extension(extension, true)
    
  end
end

# Load the AnimDor module
require_relative 'animdor'

# Create menu items for easy access
if defined?(AnimDor)
  
  # Add submenu for AnimDor
  menu = UI.menu('Plugins')
  animdor_menu = menu.add_submenu('AnimDor')
  
  # Open Doors command
  animdor_menu.add_item('Open Selected Doors') {
    model = Sketchup.active_model
    selection = model.selection.to_a
    
    if selection.empty?
      UI.messagebox('Please select door components to animate.')
    else
      AnimDor.open_doors(selection)
      UI.messagebox("Animating #{selection.length} door(s)...")
    end
  }
  
  # Close Doors command
  animdor_menu.add_item('Close Selected Doors') {
    model = Sketchup.active_model
    selection = model.selection.to_a
    
    if selection.empty?
      UI.messagebox('Please select door components to animate.')
    else
      AnimDor.close_doors(selection)
      UI.messagebox("Animating #{selection.length} door(s)...")
    end
  }
  
  # Pull Drawers command
  animdor_menu.add_item('Pull Out Selected Drawers') {
    model = Sketchup.active_model
    selection = model.selection.to_a
    
    if selection.empty?
      UI.messagebox('Please select drawer components to animate.')
    else
      # Prompt for distance
      prompts = ['Pull out distance:']
      defaults = ['12.0']
      input = UI.inputbox(prompts, defaults, 'Drawer Distance')
      
      if input
        distance = input[0].to_f
        AnimDor.pull_drawers(selection, distance)
        UI.messagebox("Animating #{selection.length} drawer(s)...")
      end
    end
  }
  
  # Separator
  animdor_menu.add_separator
  
  # Reset command (for troubleshooting)
  animdor_menu.add_item('Reset Animation State') {
    AnimDor.reset
    UI.messagebox('AnimDor state has been reset.')
  }
  
  # Configuration command
  animdor_menu.add_item('Animation Settings...') {
    prompts = ['Animation Steps:', 'Frame Delay (seconds):']
    defaults = [AnimDor::ANIMATION_STEPS.to_s, AnimDor::FRAME_DELAY.to_s]
    titles = ['Configure Animation Settings']
    
    results = UI.inputbox(prompts, defaults, titles, 'Animation Settings')
    
    if results
      # Note: In real implementation, you'd need to make these configurable
      # For now, just show the current values
      UI.messagebox("Current settings:\nSteps: #{AnimDor::ANIMATION_STEPS}\nDelay: #{AnimDor::FRAME_DELAY}s\n\nTo change these, edit animdor.rb")
    end
  }
  
  puts "AnimDor extension loaded successfully!"
  puts "Access commands from: Plugins > AnimDor"
  
end
