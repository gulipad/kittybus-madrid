class BotLogic < BaseBotLogic

	def self.setup
		set_welcome_message "Hola, soy Busybot! Te ayudo a saber cuanto le queda al bus."
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
        			reply_message " :cat: Miau! Dime el código de parada de bus para empezar!"
        			state_go 1
        		return
        		
      	end
    end
		state_action 1, :get_stop_id
		state_action 2, :get_bus_times
	end

	def self.get_stop_id
		stop_id = get_message
		response = get_emt_data(stop_id)
		if response['errorCode'] != "-1"
			@current_user.profile = {stop_id: stop_id}
			@current_user.profile = {response: response}
			reply_message  "Lo tengo! Parada #{@current_user.profile[:response]['stop']['direction']}"
			bus_lines = get_lines(response)
			reply_quick_reply "¿Cuál es tu bus?", bus_lines
			state_go
		else 
			reply_message ":cat: Oooops. No tengo datos de esta parada. Es posible que no haya autobuses a esta hora.:crying_cat_face:"
			reply_message "Me dices otra? :smiley_cat:"
		end
	end

	def self.get_bus_times
		bus_id = get_message
		times = get_times(bus_id)
		if times.length == 1
			reply_message ":cat:Miau! El bus #{times[0]}.  Es el último del día!."
			state_go 1
		else
			reply_message "El primer bus #{times[0]}, y el siguiente #{times[1]}. :cat: Miau! "
			reply_message "Buen viaje!"
			state_go 1
		end
	end
end

