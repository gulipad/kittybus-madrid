class BotLogic < BaseBotLogic

	def self.setup
		set_welcome_message "Hola, soy KittyBot! Te ayudo a saber cuanto le queda al bus en Madrid."
		set_get_started_button "bot_start_payload"
		set_bot_menu %W(Reset)
	end

	def self.cron
		broadcast_all ":princess:"
	end

	def self.bot_logic

		ENV["DOMAIN_NAME"] = "https://6ea72459.ngrok.io"

		if @request_type == "CALLBACK"
      		case @fb_params.payload
      			when "RESET_BOT"
	        		@current_user.delete
	        		reply_message "Removed all your data from our servers."
        		return
        		when "bot_start_payload"
        		reply_message ":cat: Miau! Dime el código de parada de bus para empezar!"
        		state_go 1
        		return
        		
      	end
    end
    	state_action 0, :greet
		state_action 1, :get_stop_id
		state_action 2, :get_bus_times
	end

	def self.greet
        state_go 
	end


	def self.get_stop_id
		stop_id = get_message.gsub(/[^0-9]/,"")
		"STOP ID"
		puts stop_id
		if stop_id != ""
			response = get_emt_data(stop_id)
			if response['errorCode'] != "-1"
				@current_user.profile = {stop_id: stop_id}
				@current_user.profile = {response: response}
				reply_message  "Lo tengo! :smiley_cat: Parada #{stop_id} - #{@current_user.profile[:response]['stop']['direction']}"
				@bus_lines = get_lines(response)
				reply_quick_reply "Tengo datos de estos buses!", @bus_lines
				state_go
			else 
				reply_message ":cat: Oooops. No tengo datos de esta parada. Es posible que no haya autobuses a esta hora.:crying_cat_face:"
			end	
		else
			reply_message ":cat: Todavía necesito entrenarme, de momento sólo entiendo códigos de parada!"
		end
	end

	def self.get_bus_times
		bus_id = (get_message[/(n|m|t|h|e|c)\d{1,}|\d{1,}/i]) ? get_message[/(n|m|t|h|e|c)\d{1,}|\d{1,}/i] : ""
		if bus_id != ""	 #TODO: Build array with all possible lines to avoid using regexp.
			times = get_times(bus_id)
			if times != "not_included"
				if times.length == 1
					reply_message ":cat:Miau! El bus #{times[0]}.  Es el último del día!"
					state_go 1
				else
					reply_message "El primer bus #{times[0]}, y el siguiente #{times[1]}. :cat: Miau! "
					reply_message "Buen viaje!"
					state_go 1
				end
			else
				reply_message "No tengo datos de ese bus, sorry. :crying_cat_face:"
				reply_quick_reply "Tengo estos", @bus_lines
			end
		else 
			reply_message "No entiendo amigo. Necesito una línea de bus. :cat:"
		end
	end
end

