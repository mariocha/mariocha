# animdor.rb - Animate Doors and Drawers with Progressive Animation
# SketchUp Extension for animating cabinet doors and drawers
#
# This implementation ensures:
# 1. Progressive/gradual animations using UI.start_timer
# 2. Single undo operation for all animations
# 3. Proper tracking of pending animations before committing

module AnimDor
  # Animation configuration
  ANIMATION_STEPS = 20  # Number of steps for smooth animation
  FRAME_DELAY = 0.03    # Delay between frames in seconds (30ms for ~33 fps)
  
  # Initialize module variables
  @pending_commits = 0
  @operation_started = false
  @animated_entities = []
  
  class << self
    attr_accessor :pending_commits, :operation_started, :animated_entities
    
    # Main entry point for animating doors/drawers
    # @param entities [Array<Sketchup::ComponentInstance>] Array of door/drawer components to animate
    # @param target_angle [Float] Target rotation angle in degrees
    # @param axis [Geom::Vector3d] Rotation axis
    def animate_doors(entities, target_angle, axis = Z_AXIS)
      return if entities.nil? || entities.empty?
      
      # Filter entities that need animation (not already at target angle)
      entities_to_animate = entities.select { |entity| needs_animation?(entity, target_angle) }
      
      # Handle edge case: no animations needed
      if entities_to_animate.empty?
        puts "AnimDor: No entities need animation"
        return
      end
      
      # Start operation for single undo
      model = Sketchup.active_model
      unless @operation_started
        model.start_operation('Animate Doors', true)
        @operation_started = true
      end
      
      # Initialize animation tracking
      @pending_commits = entities_to_animate.length
      @animated_entities = []
      
      # Start progressive animation for each entity
      entities_to_animate.each do |entity|
        animate_entity_progressive(entity, target_angle, axis)
      end
    end
    
    # Check if an entity needs animation based on current vs target state
    # @param entity [Sketchup::ComponentInstance] The entity to check
    # @param target_angle [Float] Target angle in degrees
    # @return [Boolean] true if animation is needed
    def needs_animation?(entity, target_angle)
      # Get current rotation angle from transformation
      # This is a simplified check - in real implementation would extract actual angle
      current_transform = entity.transformation
      
      # For this implementation, assume entity needs animation if not nil
      # Real implementation would compare current angle with target_angle
      !entity.nil? && entity.valid?
    end
    
    # Animate a single entity progressively using timer
    # @param entity [Sketchup::ComponentInstance] Entity to animate
    # @param target_angle [Float] Target rotation angle in degrees
    # @param axis [Geom::Vector3d] Rotation axis
    def animate_entity_progressive(entity, target_angle, axis)
      # Calculate starting state
      start_transform = entity.transformation
      origin = entity.bounds.center
      
      # Calculate angle increment per step
      # Convert to radians (SketchUp's .degrees method does this)
      angle_in_radians = target_angle * Math::PI / 180.0
      angle_per_step = angle_in_radians / ANIMATION_STEPS
      current_step = 0
      
      # Create timer for progressive animation
      timer_id = UI.start_timer(FRAME_DELAY, true) do
        if current_step < ANIMATION_STEPS && entity.valid?
          # Perform incremental rotation
          rotation = Geom::Transformation.rotation(origin, axis, angle_per_step)
          entity.transform!(rotation)
          
          # Track this entity for the operation
          @animated_entities << entity unless @animated_entities.include?(entity)
          
          current_step += 1
        else
          # Animation complete for this entity
          UI.stop_timer(timer_id)
          animation_complete(entity)
        end
      end
    end
    
    # Called when an individual entity animation completes
    # @param entity [Sketchup::ComponentInstance] The entity that finished animating
    def animation_complete(entity)
      @pending_commits -= 1
      
      puts "AnimDor: Animation complete for entity. Pending: #{@pending_commits}"
      
      # When all animations complete, commit the operation
      if @pending_commits <= 0
        commit_all_animations
      end
    end
    
    # Commit the operation once all animations are complete
    def commit_all_animations
      return unless @operation_started
      
      model = Sketchup.active_model
      model.commit_operation
      
      @operation_started = false
      @animated_entities = []
      
      puts "AnimDor: All animations complete. Operation committed."
    end
    
    # Helper method to animate doors to open position
    # @param doors [Array<Sketchup::ComponentInstance>] Array of door components
    def open_doors(doors)
      animate_doors(doors, 90, Z_AXIS)
    end
    
    # Helper method to animate doors to closed position
    # @param doors [Array<Sketchup::ComponentInstance>] Array of door components
    def close_doors(doors)
      animate_doors(doors, -90, Z_AXIS)
    end
    
    # Helper method to animate drawers
    # @param drawers [Array<Sketchup::ComponentInstance>] Array of drawer components
    # @param distance [Float] Distance to pull out drawer
    def pull_drawers(drawers, distance = 12.0)
      return if drawers.nil? || drawers.empty?
      
      # Filter drawers that need animation
      drawers_to_animate = drawers.select { |drawer| needs_animation?(drawer, distance) }
      
      if drawers_to_animate.empty?
        puts "AnimDor: No drawers need animation"
        return
      end
      
      # Start operation for single undo
      model = Sketchup.active_model
      unless @operation_started
        model.start_operation('Animate Drawers', true)
        @operation_started = true
      end
      
      # Initialize animation tracking
      @pending_commits = drawers_to_animate.length
      @animated_entities = []
      
      # Start progressive animation for each drawer
      drawers_to_animate.each do |drawer|
        animate_drawer_progressive(drawer, distance)
      end
    end
    
    # Animate a drawer progressively
    # @param drawer [Sketchup::ComponentInstance] Drawer to animate
    # @param distance [Float] Distance to pull out
    def animate_drawer_progressive(drawer, distance)
      # Get the drawer's current transformation and direction
      start_transform = drawer.transformation
      
      # Calculate movement vector (typically along X axis for drawers)
      # This assumes drawers pull out along their local X axis
      move_vector = drawer.transformation.xaxis
      distance_per_step = distance / ANIMATION_STEPS
      
      # Scale the vector to the step distance
      if move_vector.respond_to?(:length=)
        # SketchUp Vector3d method
        step_vector = move_vector.clone
        step_vector.length = distance_per_step
      else
        # Manual vector scaling for testing
        magnitude = Math.sqrt(move_vector[0]**2 + move_vector[1]**2 + move_vector[2]**2)
        scale = distance_per_step / magnitude
        step_vector = [move_vector[0] * scale, move_vector[1] * scale, move_vector[2] * scale]
      end
      
      current_step = 0
      
      # Create timer for progressive animation
      timer_id = UI.start_timer(FRAME_DELAY, true) do
        if current_step < ANIMATION_STEPS && drawer.valid?
          # Perform incremental translation
          translation = Geom::Transformation.translation(step_vector)
          drawer.transform!(translation)
          
          # Track this entity for the operation
          @animated_entities << drawer unless @animated_entities.include?(drawer)
          
          current_step += 1
        else
          # Animation complete for this drawer
          UI.stop_timer(timer_id)
          animation_complete(drawer)
        end
      end
    end
    
    # Reset module state (useful for testing or error recovery)
    def reset
      @pending_commits = 0
      @operation_started = false
      @animated_entities = []
      puts "AnimDor: State reset"
    end
  end
end

# Example usage (commented out for plugin context):
# 
# # Get selected components (doors or drawers)
# model = Sketchup.active_model
# selection = model.selection
# 
# # Animate selected doors to open
# AnimDor.open_doors(selection.to_a)
# 
# # Or animate drawers
# AnimDor.pull_drawers(selection.to_a, 12.0)
