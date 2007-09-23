require 'swiby'

class ButtonClickedModel
	attr_accessor :buttonEnabled
end

model = ButtonClickedModel.new

model.buttonEnabled = true

Frame {
	
	title "Button Demo"
	
	content {
		FlowPanel {
			content [
				Button {
					text "Disable middle button"
                    mnemonic "D"
                    tooltip "Click this button to disable the middle button"
                    icon "http://java.sun.com/docs/books/tutorial/uiswing/components/examples/images/right.gif"
                    verticalTextPosition CENTER
                    horizontalTextPosition LEADING
					enabled bind { model.buttonEnabled }
                    action {
                         model.buttonEnabled = false
                    }
                },
                Button {
                    text "Middle button"
                    mnemonic "M"
                    tooltip "This middle button does nothing when you click it."
                    icon "http://java.sun.com/docs/books/tutorial/uiswing/components/examples/images/middle.gif"
                    verticalTextPosition BOTTOM
                    horizontalTextPosition CENTER
					enabled bind { model.buttonEnabled }
                },
                Button {
                    text "Enable middle button"
                    mnemonic "E"
                    tooltip "Click this button to enable the middle button"
                    icon "http://java.sun.com/docs/books/tutorial/uiswing/components/examples/images/left.gif"
					enabled bind { not model.buttonEnabled }
                    action {
                         model.buttonEnabled = true
                    }
                }
			]
		}
	}
	
	visible true
	
}

