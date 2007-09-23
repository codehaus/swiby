require 'swiby'

class Item 

	def initialize(map = [])
		map.each do |attr, value|
			send "#{attr}=".to_sym, value
		end unless map.nil?
	end
	
	attr_accessor :id
	attr_accessor :productId
	attr_accessor :description
	attr_accessor :inStock
	attr_accessor :quantity
	attr_accessor :listPrice
	attr_accessor :totalCost
	
	def totalCost
		@quantity*@listPrice
	end
	
end

class Cart
	
	attr_accessor :items
	
	def subTotal

		total = 0
		
		@items.each { |item|
			total = total + item.totalCost
		}
		
		total
		
	end
	
end

cart = Cart.new

cart.items = [
	Item.new(
		:id => "UGLY",
		:productId => "D100",
		:description => "BullDog",
		:inStock => true,
		:quantity => 1,
		:listPrice => 97.50
	),
	Item.new(
		:id => "BITES",
		:productId => "D101",
		:description => "Pit Bull",
		:inStock => true,
		:quantity => 1,
		:listPrice => 127.50
	)
]

Frame {
	
	content {
		Label {
			html bind { "<html> 
					<h2 align='center'>Shopping Cart</h2>
					<table align='center' border='0' bgcolor='#008800' cellspacing='2' cellpadding='5'>
                       <tr bgcolor='#cccccc'>
                          <td><b>Item ID</b></td>
                          <td><b>Product ID</b></td>
                          <td><b>Description</b></td>
                          <td><b>In Stock?</b></td>
                          <td><b>Quantity</b></td>
                          <td><b>List Price</b></td>
                          <td><b>Total Cost</b></td>
                          <td> </td>
                       </tr>

					   <% if cart.items.empty? %>
						 	<tr bgcolor='#FFFF88'><td colspan='8'><b>Your cart is empty.</b></td></tr>
					   <% else %>
					      <% cart.items.each do |item| %>
							  <tr bgcolor='#FFFF88'>
							  <td><%= item.id %></td>
							  <td><%= item.productId %></td>
							  <td><%= item.description %></td>
							  
							  <td><%= if item.inStock then 'Yes' else 'No' end %></td>
							  
							  <td><%= item.quantity %></td>
							  <td align='right'><%= item.listPrice %></td>
							  <td align='right'><%= item.totalCost %></td>
							  <td> </td>
							  </tr>
					      <% end %>
					   <% end %>
					   
					   <tr bgcolor='#FFFF88'>
                          <td colspan='7' align='right'>
                          <b>Sub Total: $<%= cart.subTotal %></b>
                          </td>
                          <td> </td>
                       </tr>
				    </table>
				</html>"
			}
		}
	}
	
	visible true
	
}

Frame {
	
	content {
		Button {
			text "Clear cart"
			mnemonic "c"
			action {
				cart.items = []
			}
		}
	}
	
	visible true
	
}

