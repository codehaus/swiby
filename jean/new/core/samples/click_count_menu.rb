require 'swiby'

class ButtonClickedModel
	attr_accessor :numClicks
end

model = ButtonClickedModel.new

model.numClicks = 0

Frame {
	
	width 200
	
	menus {
		Menu {
			text "File"
			mnemonic "F"
			items {
				MenuItem {
					text "Exit"
					mnemonic "X"
					accelerator {
						modifier CTL
						key_stroke Q
					}
					action {
						java.lang.System.exit 0
					}
				}
			}
		}
	}
	
	content {
		GridPanel {
			border {
				Empty {
				   top 30
				   left 30
				   bottom 30
				   right 30
				}
			}
			rows 2
			columns 1
			vgap 10
			cells {
				[Button {
					text "I'm a button!"
					mnemonic "I"
					action {
						model.numClicks = model.numClicks + 1
					}
				},
				Label {
					text bind {"Number of button clicks: #{model.numClicks}"}
				}]
			}
		}
	}
	
	visible true
	
}

