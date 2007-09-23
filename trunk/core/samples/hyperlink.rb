require 'swiby'

class ButtonClickeddModel
	attr_accessor :numClicks
end

model = ButtonClickeddModel.new

model.numClicks = 0

Frame {
	
	width 200
	
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
				[Label {
					html bind { %{
						<html>
							<a href='model.numClicks = model.numClicks + 1'>
								I'm a hypelink
							</a>
						 </html>
					} }
				},
				Label {
					text bind {"Number of button clicks: #{model.numClicks}"}
				}]
			}
		}
	}
	
	visible true
	
}

