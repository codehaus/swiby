require 'swiby'

class EmployeeModel
	attr_accessor :employees
	attr_accessor :selectedEmployee
	attr_accessor :newHireName
end

model = EmployeeModel.new

model.employees = 
	["Alan Sommerer",
	 "Alison Huml",
	 "Kathy Walrath",
	 "Lisa Friendly",
	 "Mary Campione",
	 "Sharon Zakhour"]

model.selectedEmployee = 0

Frame {
	title  "ListBox Example"
	content {
		BorderPanel {
			center ListBox {
				cells bind(model, :employees)
				selection bind(model, :selectedEmployee)
			}
			bottom FlowPanel {
				content [
					Button {
						text "Fire"
						action {
							model.employees.delete_at model.selectedEmployee
						}
					},
					RigidArea {
						width 5
					},
					TextField {
						columns 30
						value bind(model, :newHireName)
					},
					RigidArea {
						width 5
					},
					Button {
						text "Hire"
						enabled bind { not model.newHireName.nil? and model.newHireName.length > 0 }
						action {
							
							model.employees.push model.newHireName

							model.newHireName = ""

							if model.employees.size == 1
								model.selectedEmployee = 0
							else
								model.selectedEmployee += 1
							end
							
						}
					}
				]
			}
		}
	}
	
	visible true
	
}
		
