# ISSUE: The animdor method is not creating a single undoable operation
# 
# PROBLEM:
# The start_operation and commit_operation are being used, but the UI.start_timer 
# callbacks execute AFTER commit_operation is called, so those operations are not 
# included in the transaction.
#
# SOLUTION:
# Move commit_operation into a callback that executes after all animations complete,
# or use a different approach that keeps operations within the transaction.

def animdor(cab)
  @mod.start_operation('Anim', true)
  
  # Track active timers to know when all animations complete
  @active_timers ||= []
  @pending_commits ||= 0
  
  cab.entities.each do |e|
    if e.is_a? Sketchup::Group
    next unless e.name == LGH['retn_door']
      @retn_pt = e.transformation.origin
    end #do
  end
  cab.entities.each do |e|
    if e.is_a? Sketchup::Group
    next unless e.name == LGH['wid_door']
      @widt_pt = e.transformation.origin
    end #do
  end
  cab.entities.each do |e|
    if e.is_a? Sketchup::Group
    next unless e.name == LGH['top']
      @c_top_pt = e.transformation.origin
    end #do
  end

  cab.entities.each do |e|
    if e.is_a? Sketchup::Group
      op = e.get_attribute(@dict, 'op')
      horhand = cab.get_attribute(@dict,'horhand')
      count = 0
      if e.name[0, 4] == LGH['door'][0, 4]
        pt = e.transformation.origin
        if op != true
          op_ang = -90/4
          op_ang = 90/4 if e.name == LGH["door_rig"] || @handlef == true
          @pending_commits += 1
          timer_id = UI.start_timer(0.1, true) {
            opn_door(e, pt, op_ang)
            count += 1
            if count == 4
              UI.stop_timer timer_id
              @pending_commits -= 1
              check_and_commit_operation
            end
          }
          e.set_attribute(@dict, 'op', true)
        elsif op == true
          cl_ang = 92
          cl_ang = -88 if e.name == LGH["door_rig"] || @handlef == true
          close(e, pt, cl_ang)
          e.set_attribute(@dict, 'op', false)
        end # if op

      elsif e.name.include? 'hor_' or e.name.include? 'ne_' #in 'one' or 'une'
        pt = e.transformation.origin
        if op != true
          open_horiz(e, pt)
          e.set_attribute(@dict, 'op', true)
          elsif op == true
          close_hor(e, pt)
          e.set_attribute(@dict, 'op', false)
        end # if op

      elsif e.name == LGH['drawer']
        if op != true
          @pending_commits += 1
          timer_id = UI.start_timer(0.1, true) {
            opn_drawr(e)
            count += 1
            if count == 14
              UI.stop_timer timer_id
              @pending_commits -= 1
              check_and_commit_operation
            end
          }
          e.set_attribute(@dict, 'op', true)
        elsif op == true
          close_drawr(e)
          e.set_attribute(@dict, 'op', false)
        end # if op

      elsif e.name.include? 'sos'
        ctop = cab.get_attribute(@dict, 'ctop')
        heit = cab.get_attribute(@dict, 'heit')
        ptor = Geom::Point3d.new(0, 0, 0)
        ptor[1] = ptor[1] - @dept
        ptor[2] = ptor[2] + heit- ctop

        dh = cab.get_attribute(@dict,'htir1')
        pt = ptor
        pt[2] = pt[2] - dh.to_f

        if op != true
          @pending_commits += 1
          timer_id = UI.start_timer(0.1, true) {
            open_sos(e, pt)
            count += 1
            if count == 8
              UI.stop_timer timer_id
              @pending_commits -= 1
              check_and_commit_operation
            end
          }
          e.set_attribute(@dict, 'op', true)
        elsif op == true
          close_sos(e, pt)
          e.set_attribute(@dict, 'op', false)
        end # if op

      elsif e.name == LGH['retn_door']  ## ò planché
        corn_pt = e.transformation.origin
        corn_pt = @widt_pt if @hand_ret == true
        if @typ == 'coin'
          if op != true
            op_ang = -120/4
            op_ang = 120/4  if @hand_ret == true #or @z > 30
            @pending_commits += 1
            timer_op = UI.start_timer(0.1, true) {
              opn_corner(e, corn_pt, op_ang)
              count += 1
              if count == 4
                UI.stop_timer timer_op
                @pending_commits -= 1
                check_and_commit_operation
              end
            }
            e.set_attribute(@dict, 'op', true)
          elsif op == true
            cl_ang = 120
            cl_ang = -120 if @hand_ret == true
            close_corner(e, corn_pt, cl_ang)
            e.set_attribute(@dict, 'op', false)
          end # if op
        elsif @typ == 'coinup'
          corn_pt = @widt_pt
          if op != true
            op_ang = 44/4
            @pending_commits += 1
            timer_id = UI.start_timer(0.1, true) {
              opn_corner(e, corn_pt, op_ang)
              count += 1
              if count == 4
                UI.stop_timer timer_id
                @pending_commits -= 1
                check_and_commit_operation
              end
            }
            e.set_attribute(@dict, 'op', true)
          elsif op == true
            cl_ang = -44
            close_corner(e, corn_pt, cl_ang)
            e.set_attribute(@dict, 'op', false)
          end # if op
        end # if @typ

      elsif e.name == LGH['wid_door']
        if @typ == 'coin'   ## ò planché
          corn_pt = @retn_pt
          corn_pt = @widt_pt if @hand_ret == true
          if op != true
            op_ang = -120/4
            op_ang = 120/4 if @hand_ret == true
            @pending_commits += 1
            timer_id = UI.start_timer(0.1, true) {
              opn_corner(e, corn_pt, op_ang)
              count += 1
              if count == 4
                UI.stop_timer timer_id
                @pending_commits -= 1
                check_and_commit_operation
              end
            }
            e.set_attribute(@dict, 'op', true)
          elsif op == true
            cl_ang = 120
            cl_ang = -120 if @hand_ret == true
            close_corner(e, corn_pt, cl_ang)
            e.set_attribute(@dict, 'op', false)
          end # if op
        elsif @typ == 'coinup'
          corn_pt = @widt_pt
          if op != true
            op_ang = -44/4
            @pending_commits += 1
            timer_id = UI.start_timer(0.1, true) {
              opn_corner(e, corn_pt, op_ang)
              count += 1
              if count == 4
                UI.stop_timer timer_id
                @pending_commits -= 1
                check_and_commit_operation
              end
            }
            e.set_attribute(@dict, 'op', true)
          elsif op == true
            cl_ang = 44
            close_corner(e, corn_pt, cl_ang)
            e.set_attribute(@dict, 'op', false)
          end # if op
        end # if @typ
      end #if e.name
    end #if e.is
  end #do

  # Commit immediately if no timers were started
  check_and_commit_operation
end #animdor

# Helper method to commit operation only after all timers complete
def check_and_commit_operation
  if @pending_commits == 0
    @mod.commit_operation
  end
end
