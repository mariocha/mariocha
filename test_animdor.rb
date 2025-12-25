# test_animdor.rb - Test and example usage for AnimDor module
# This file demonstrates how to use the AnimDor module and provides test scenarios

require_relative 'animdor'

module AnimDorTest
  # Mock classes for testing without SketchUp environment
  module MockSketchUp
    class MockEntity
      attr_accessor :transformation, :valid
      attr_reader :bounds
      
      def initialize(name = "Entity")
        @name = name
        @transformation = MockTransformation.new
        @bounds = MockBounds.new
        @valid = true
      end
      
      def valid?
        @valid
      end
      
      def transform!(transformation)
        # Apply transformation
        @transformation = @transformation.multiply(transformation)
      end
    end
    
    class MockTransformation
      attr_accessor :origin, :xaxis, :yaxis, :zaxis
      
      def initialize
        @origin = [0, 0, 0]
        @xaxis = [1, 0, 0]
        @yaxis = [0, 1, 0]
        @zaxis = [0, 0, 1]
      end
      
      def multiply(other)
        # Simplified transformation multiplication
        self
      end
      
      def self.rotation(origin, axis, angle)
        new
      end
      
      def self.translation(vector)
        new
      end
    end
    
    class MockBounds
      def center
        [0, 0, 0]
      end
    end
    
    class MockModel
      attr_accessor :operation_active
      
      def initialize
        @operation_active = false
      end
      
      def start_operation(name, transparent = false)
        @operation_active = true
        puts "Mock: Starting operation '#{name}'"
      end
      
      def commit_operation
        @operation_active = false
        puts "Mock: Committing operation"
      end
    end
    
    class MockUI
      @@timers = {}
      @@timer_id = 0
      
      def self.start_timer(delay, repeat = false, &block)
        @@timer_id += 1
        timer_id = @@timer_id
        @@timers[timer_id] = { delay: delay, repeat: repeat, block: block }
        puts "Mock: Started timer #{timer_id} with delay #{delay}s"
        timer_id
      end
      
      def self.stop_timer(timer_id)
        @@timers.delete(timer_id)
        puts "Mock: Stopped timer #{timer_id}"
      end
      
      def self.execute_timers(steps = 1)
        steps.times do
          @@timers.each do |id, timer|
            timer[:block].call
          end
        end
      end
      
      def self.reset_timers
        @@timers = {}
        @@timer_id = 0
      end
    end
  end
  
  # Test scenarios
  class TestRunner
    def self.run_all_tests
      puts "\n" + "="*60
      puts "Running AnimDor Tests"
      puts "="*60
      
      test_single_door_animation
      test_multiple_doors_animation
      test_no_animation_needed
      test_drawer_animation
      test_reset_functionality
      
      puts "\n" + "="*60
      puts "All tests completed"
      puts "="*60
    end
    
    def self.test_single_door_animation
      puts "\n--- Test: Single Door Animation ---"
      
      # Setup
      AnimDor.reset
      door = MockSketchUp::MockEntity.new("Door1")
      
      # Mock SketchUp environment
      stub_sketchup_environment
      
      # Execute
      AnimDor.open_doors([door])
      
      # Verify
      assert_equal(1, AnimDor.pending_commits, "Should have 1 pending commit")
      assert_true(AnimDor.operation_started, "Operation should be started")
      
      # Simulate animation completion
      AnimDor.pending_commits.times { AnimDor.animation_complete(door) }
      
      assert_equal(0, AnimDor.pending_commits, "Should have 0 pending commits after completion")
      assert_false(AnimDor.operation_started, "Operation should be committed")
      
      puts "✓ Single door animation test passed"
    end
    
    def self.test_multiple_doors_animation
      puts "\n--- Test: Multiple Doors Animation ---"
      
      # Setup
      AnimDor.reset
      doors = [
        MockSketchUp::MockEntity.new("Door1"),
        MockSketchUp::MockEntity.new("Door2"),
        MockSketchUp::MockEntity.new("Door3")
      ]
      
      stub_sketchup_environment
      
      # Execute
      AnimDor.open_doors(doors)
      
      # Verify
      assert_equal(3, AnimDor.pending_commits, "Should have 3 pending commits")
      assert_true(AnimDor.operation_started, "Operation should be started")
      
      # Simulate animations completing one by one
      doors.each_with_index do |door, i|
        AnimDor.animation_complete(door)
        remaining = doors.length - i - 1
        assert_equal(remaining, AnimDor.pending_commits, 
                     "Should have #{remaining} pending commits")
      end
      
      assert_false(AnimDor.operation_started, "Operation should be committed after all complete")
      
      puts "✓ Multiple doors animation test passed"
    end
    
    def self.test_no_animation_needed
      puts "\n--- Test: No Animation Needed (Edge Case) ---"
      
      # Setup
      AnimDor.reset
      stub_sketchup_environment
      
      # Execute with empty array
      AnimDor.open_doors([])
      
      # Verify
      assert_equal(0, AnimDor.pending_commits, "Should have 0 pending commits")
      assert_false(AnimDor.operation_started, "Operation should not be started")
      
      puts "✓ No animation needed test passed"
    end
    
    def self.test_drawer_animation
      puts "\n--- Test: Drawer Animation ---"
      
      # Setup
      AnimDor.reset
      drawers = [
        MockSketchUp::MockEntity.new("Drawer1"),
        MockSketchUp::MockEntity.new("Drawer2")
      ]
      
      stub_sketchup_environment
      
      # Execute
      AnimDor.pull_drawers(drawers, 12.0)
      
      # Verify
      assert_equal(2, AnimDor.pending_commits, "Should have 2 pending commits")
      assert_true(AnimDor.operation_started, "Operation should be started")
      
      # Simulate completion
      drawers.each { |drawer| AnimDor.animation_complete(drawer) }
      
      assert_false(AnimDor.operation_started, "Operation should be committed")
      
      puts "✓ Drawer animation test passed"
    end
    
    def self.test_reset_functionality
      puts "\n--- Test: Reset Functionality ---"
      
      # Setup with some state
      AnimDor.pending_commits = 5
      AnimDor.operation_started = true
      
      # Execute
      AnimDor.reset
      
      # Verify
      assert_equal(0, AnimDor.pending_commits, "Pending commits should be reset to 0")
      assert_false(AnimDor.operation_started, "Operation started should be reset to false")
      
      puts "✓ Reset functionality test passed"
    end
    
    # Helper methods
    def self.stub_sketchup_environment
      # Create mock Sketchup module if it doesn't exist
      unless defined?(Sketchup)
        Object.const_set(:Sketchup, Module.new)
        Sketchup.define_singleton_method(:active_model) { MockSketchUp::MockModel.new }
      end
      
      unless defined?(UI)
        Object.const_set(:UI, MockSketchUp::MockUI)
      end
      
      unless defined?(Geom)
        Object.const_set(:Geom, Module.new)
        Geom.const_set(:Transformation, MockSketchUp::MockTransformation)
      end
      
      unless defined?(Z_AXIS)
        Object.const_set(:Z_AXIS, [0, 0, 1])
      end
    end
    
    def self.assert_equal(expected, actual, message = "")
      unless expected == actual
        raise "Assertion failed: #{message}. Expected: #{expected}, Got: #{actual}"
      end
    end
    
    def self.assert_true(value, message = "")
      unless value
        raise "Assertion failed: #{message}. Expected true, got #{value}"
      end
    end
    
    def self.assert_false(value, message = "")
      if value
        raise "Assertion failed: #{message}. Expected false, got #{value}"
      end
    end
  end
end

# Run tests if this file is executed directly
if __FILE__ == $0
  AnimDorTest::TestRunner.run_all_tests
end
