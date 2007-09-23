require 'swiby'

class Model

	attr_accessor :tabPlacement
	attr_accessor :tabLayout
	attr_accessor :selectedTab
	
	attr_reader :tabCount
	
	def tabCount=(value)
		@tabCount = value.to_i
	end
	
end

model = Model.new

model.tabPlacement = TOP
model.tabLayout = WRAP
model.tabCount = 5
model.selectedTab = 3

Frame {
	
	height 300
	width 400
	
	content {
		TabbedPane {
			tabPlacement bind { model.tabPlacement }
			tabLayout bind { model.tabLayout }
			tabs bind {
				(1..model.tabCount).collect do |i|
					Tab {
						title "Tab #{i}"
						tooltip "Tooltop #{i}"
					}
				end
			}
			selectedIndex bind { model.selectedTab }
		}
	}
	
	visible true
	
}

class DemoModel

	attr_reader :layoutIndex
	attr_reader :placementIndex

	def initialize(model)
		@model = model
	end
	
	def layoutIndex=(value)
		
		@model.tabLayout = [SCROLL, WRAP][value]
		
		@layoutIndex = value
		
	end
	
	def placementIndex=(value)
	
		@model.tabPlacement = [TOP, LEFT, RIGHT, BOTTOM][value]
		 
		@placementIndex = value
		 
	end
	
end

demo = DemoModel.new(model)

demo.layoutIndex = 1
demo.placementIndex = 0

Frame {
	
	title bind {"Tab count is #{model.tabCount}"}
	
	width 200
	
	content {
		GridPanel {
			border {
				Empty {
				   top 5
				   left 5
				   bottom 5
				   right 5
				}
			}
			rows 3
			columns 2
			hgap 10
			vgap 5
			cells {[
				SimpleLabel {
					text "Number of tabs:"
				},
				TextField {
					value bind(model, :tabCount)
				},
				SimpleLabel {
					text "Placement:"
				},
				ComboBox {
					cells {[
						"Top", "Left", "Right", "Bottom"
					]}
					selection bind(demo, :placementIndex)
				},
				SimpleLabel {
					text "Layout:"
				},
				ComboBox {
					cells {[
						"Scroll", "Wrap"
					]}
					selection bind(demo, :layoutIndex)
				}				
			]}
		}
	}
	
	visible true
	
}

