#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/draw_panel'

class DrawingTest < ManualTest

  manual 'Layers w/ 3 overlaping squares' do
    
    frame {

      title 'Layers w/ 3 overlaping squares'
      
      width 350
      height 400
      
      draw_panel { |graphics|
      
        graphics.layer(:bg) { |bg|
          bg.gradient 0, 0, Color::BLUE.darker, graphics.width, graphics.height, Color::GRAY
          bg.fill_rect 0, 0, graphics.width, graphics.height
        }
        
        graphics.layer(:L1) { |g|
          g.color Color::WHITE
          g.fill_rect 20, 20, 200, 200
        }
        
        graphics.layer(:L2) { |g|
          g.color Color::RED
          g.fill_rect 40, 40, 200, 200
        }
        
        graphics.layer(:L3) { |g|
          g.color Color::MAGENTA
          g.fill_rect 60, 60, 200, 200
        }
      
      }
      
      north
        label '<html><font size=4>You should see 3 overlapping squares<br>
        (from back to front a white, a red and a magenta)</font>', :report

      visible true
      
    }
    
  end
  
  manual 'Does not redraw unchanged layers' do
    
    redraw_count = 0
    bg_redraw_count = 0
    l1_redraw_count = 0
    
    f = frame {
    
      title 'Does not redraw unchanged layers'
    
      width 350
      height 400
    
      draw_panel { |graphics|
      
        redraw_count += 1
      
        graphics.layer(:bg) { |bg|
          bg_redraw_count += 1
          bg.color Color::BLACK
          bg.fill_rect 0, 0, graphics.width, graphics.height
        }
        
        graphics.layer(:L1) { |g|
        
          l1_redraw_count += 1
          
          @color_l1 = @color_l1 ? Color::RED : Color::WHITE
        
          g.color @color_l1
          g.fill_rect 20, 20, 200, 200
          
        }
        
        graphics.layer(:L2) { |g|
          
          @color_l2 = @color_l2 ? Color::BLUE : Color::RED
          
          g.color @color_l2
          g.fill_rect 40, 70, 200, 200
          
        }
        
      }
      
      north
        label '', :report
    
      visible true
      
    }

    Thread.new do
      
      sync_swing_thread {f[0].repaint; f[0].layer(:L2).repaint}
      
      sync_swing_thread do
          
          report = ""
          
          if redraw_count != 2
            report = "Expected redraw count did not happen"
          elsif bg_redraw_count == 0
            report = "Background was not redrawn"
          elsif l1_redraw_count == 0
            report = "Layer 1 was not redrawn"
          elsif bg_redraw_count == 1 and l1_redraw_count == 1
          else
            report = "Expected redraws were wrong<br>
               (background redraw count #{bg_redraw_count} instead of 1<br>
               (layer 1 redraw count #{l1_redraw_count} instead of 1"
          end
          
          if report.length == 0
            report = "Redraw did happen as expected<br>You should see a white and a blue square with a black background"
          else
            report = "<font color=red>#{report}</font>"
          end
          
          f.find(:report).text = "<html><font size=4>#{report}</font>"
          
      end
        
    end
  
  end

  manual 'Use pen and layers' do
    
    frame {

      title 'Use pen and layers'

      width 350
      height 400

      north
        label '<html>You should see a house with<br><ul><li>a black door,<li>two blue windows,<li>a yellow round window<li>a red roof.'
        
      center
        draw_panel { |graphics|
        
          graphics.layer(:bg) { |bg|
            bg.color Color::WHITE
            bg.fill_rect 0, 0, graphics.width, graphics.height
          }
          
          graphics.layer(:roof) { |g|
          
            g.antialias = true
            
            pen = g.create_pen
            
            pen.stroke_width 3
            pen.color Color::RED
            
            pen.move_to 20, 100
            pen.down
            pen.move_to 60, 60
            pen.move_to 180, 60
            pen.move_to 220, 100
            
            roof = g.polygon [28, 97], [62, 63], [178, 63], [212, 97]
            
            pen.fill_polygon roof
            
          }
          
          graphics.layer(:building) { |g|
          
            g.antialias = true
            
            pen = g.create_pen
            
            pen.stroke_width 3
            pen.color Color.new(128, 64, 0)
            
            pen.move_to 20, 100
            pen.down
            pen.rect 200, 80
            pen.fill_rect 200, 80
            
          }
          
          graphics.layer(:windows) { |g|
          
            g.antialias = true
            
            pen = g.create_pen
            
            pen.move_to 30, 110
            pen.down
            pen.color Color::YELLOW
            pen.fill_oval 30, 30
            pen.up
            pen.move_to 120, 110
            pen.down
            pen.color Color::BLUE.darker
            pen.fill_rect 40, 30
            pen.up
            pen.move_to 170, 110
            pen.down
            pen.fill_rect 40, 30
            
          }
          
          graphics.layer(:door) { |g|
          
            g.antialias = true
            
            pen = g.create_pen
            
            pen.move_to 70, 130
            pen.down
            pen.color Color::BLACK
            pen.fill_rect 30, 50
            
          }
          
          graphics.layer(:texts) { |g|
          
            g.antialias = true
            
            pen = g.create_pen
            
            pen.move_to 120, 145
            pen.down
            pen.color Color::WHITE
            pen.box 80, 30, "Home"
            
          }
        
        }

      visible true
      
    }
    
  end
  
  manual 'All kind of drawing primitives' do
    
    frame {

      title 'All kind of drawing primitives'

      width 500
      height 400

      north
        label '<html>You should see a geometric forms with their desciption.'
        
      center
        draw_panel { |graphics|
        
          graphics.layer(:layer) { |g|
          
            g.antialias = true
            
            g.background Color::WHITE
            g.clear
            
            draw_shapes g, 'normal'
            
            g.translate 30, 100
            draw_shapes g, 'origin moved'
            
            g.rotate Math::PI, 200, 80
            draw_shapes g, 'rotated'
            
            g.scale 0.7
            g.rotate -Math::PI, 300, -20
            draw_shapes g, 'scaled down'
            
          }
          
        }
        
        def draw_shapes g, message
          
          pen = g.create_pen
          
          pen.move_to 10, 10
          pen.down
          pen.write "#{message} - Pairs of shapes and filled shapes: polygon, rectangle, oval, arc"
          
          pen.stroke_width 3
          pen.color Color::RED
          
          pol = g.polygon [10, 60], [30, 20], [50, 60]            
          pen.polygon pol
          
          pol = g.polygon [60, 60], [80, 20], [100, 60]
          pen.fill_polygon pol

          pen.up
          pen.move_to 110, 20
          pen.down
          pen.rect 40, 40
          
          pen.up
          pen.move_to 160, 20
          pen.down
          pen.fill_rect 40, 40
          
          pen.up
          pen.move_to 210, 20
          pen.down
          pen.oval 40, 40
          
          pen.up
          pen.move_to 260, 20
          pen.down
          pen.fill_oval 40, 40
          
          pen.up
          pen.move_to 310, 20
          pen.down
          pen.arc 40, 40, 90, 90
          
          pen.up
          pen.move_to 360, 20
          pen.down
          pen.fill_arc 40, 40, 90, 90
          
        end

      visible true
      
    }
    
  end

  manual 'Layer scaling' do
    
    frame {

      title 'Layer scaling'
      
      width 25
      height 25
      
      draw_panel(:resize_always => true) { |graphics|
      
        graphics.drawing_size 240, 240
        
        graphics.layer(:bg) { |bg|
          bg.background Color::BLACK
          bg.clear
        }

        graphics.layer(:L1) { |g|
          
          g.antialias = true
          
          g.color Color::WHITE
          
          20.times do |i|
            g.draw_line 0, i * 10 + 10, i * 10 + 10, 0
          end
          
        }
        
        graphics.layer(:L2) { |g|
          
          g.antialias = true
          
          g.color Color::GREEN
          
          20.times do |i|
            i += 20
            g.draw_line 0, i * 10 + 10, i * 10 + 10, 0
          end
          
        }
        
        graphics.layer(:L3) { |g|
          g.antialias = true
          g.color Color::YELLOW
          g.draw_oval 30, 30, g.drawing_width - 120, g.drawing_height - 120
        }
      
      }
      
      north
        label '<html><font size=4>You should see green and white lines, 1 yellow circle,<br>
        with a black background.<br>
        When resizing all drawings should render smoothly
        (no bitmap scaling) and background should be all black.<br><br>
        Resize the window very small and very big, the rendenring,<br>
        should be scaled but remain unchanged.</font>'

      visible true
      
    }
    
  end
  
end