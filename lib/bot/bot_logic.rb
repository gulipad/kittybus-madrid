class BotLogic < BaseBotLogic
	
	def self.setup
		set_welcome_message "Hola, soy KittyBot! Te ayudo a saber cuánto le queda al bus en Madrid."
		set_get_started_button "bot_start_payload"
		set_bot_menu %W(Reset)
	end

	def self.cron
		broadcast_all ":princess:"
	end

	def self.bot_logic

		ENV["DOMAIN_NAME"] = "https://11e74b49.ngrok.io"

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
		state_action 3, :handle_location
	end

	def self.greet
        state_go 
	end

	def self.get_stop_id
		stop_id = get_message
		info = get_profile(@current_user.fb_id)
		first_name = info["first_name"]
		@current_user.profile = {first_name: first_name}
		ai_response = ai_response(stop_id)
		
		if stop_id.match(/gr{1,}a{1,}ci{1,}a{1,}s{1,}|gra{1,}zie{1,}|thank|thx|thnks/i)
			typing_indicator
			reply_message ":smiley_cat: No hay de que! Aquí estoy cuando quieras. Miau!"
		elsif ai_response[:result][:metadata][:intentName] == 'greeting'
			puts '#####################'
			typing_indicator
			ai_reply = sprintf(ai_response[:result][:fulfillment][:speech].to_s, @current_user.profile[:first_name])
			reply_message ai_reply
		elsif ai_response[:result][:metadata][:intentName] == 'locationRequest'
			typing_indicator
			reply_location_button("Para eso necesito tu localización")
			state_go 3
		else stop_id = get_message.gsub(/[^0-9]/,"")
			if stop_id != ""
				typing_indicator
				response = get_emt_data(stop_id)
				if response['errorCode'] != "-1"
					@current_user.profile = {stop_id: stop_id}
					@current_user.profile = {response: response}
					reply_message  ["Lo tengo! :smiley_cat: Parada #{stop_id} - #{@current_user.profile[:response]['stop']['direction']}", "Genial! :smiley_cat: Parada #{stop_id} - #{@current_user.profile[:response]['stop']['direction']}"].sample
					@bus_lines = get_lines(response)
					reply_quick_reply "Tengo datos de estos buses!", @bus_lines
					puts @bus_lines
					state_go
				else 
					reply_message ":cat: Oooops. No tengo datos de esta parada. Es posible que no haya autobuses a esta hora.:crying_cat_face:"
				end	
			else
				reply_message ":cat: Todavía necesito entrenarme, de momento sólo entiendo códigos de parada!"
			end
		end		
	end

	def self.get_bus_times
		regexp = get_message[/(n|m|t|h|e|c)\d{1,}|\d{1,}|(\s|^)(U|H|F|G|A)(\s|$)/i]
		bus_id = (regexp) ? regexp.strip : ""
		if bus_id != ""	
			typing_indicator
			times = get_times(bus_id)
			if times != "not_included"
				if times.length == 1
					reply_message ":cat:Miau! El bus #{times[0]}.  Es el último del día!"
					state_go 1
				else
					reply_message ["El primer bus #{times[0]}, y el siguiente #{times[1]}. :cat: Miau! ", "Ok! :cat: Tu primer bus #{times[0]}, y hay otro que #{times[1]}."].sample
					reply_message ["Buen viaje #{@current_user.profile[:first_name]}!", "Estoy aqui cuando quieras!:heart_eyes_cat:", "Ten un viaje estupendo! :cat:"].sample
					state_go 1
				end
			else
				reply_message "No tengo datos de ese bus, sorry. :crying_cat_face:"
				reply_quick_reply "Tengo estos", @bus_lines
			end
		else 
			reply_message "No he entendido eso. Necesito una línea de bus. :cat:"
		end
	end

	def self.handle_location
		if @request_type == "LOCATION"
			typing_indicator
			lat =  @msg_meta["coordinates"]["lat"]
			lng = @msg_meta["coordinates"]["long"]
			radius = 200
			response = get_close_stops(lat, lng, radius)
			reply_quick_buttons "Aquí tienes #{@current_user.profile[:first_name]}! Las paradas a un radio de 200 metros de tu posición. Miau!", response
			state_go 1
		else
			reply_message "No he captado localización, volvamos a empezar :smiley_cat:. Me das una parada? "
			state_go 1
		end
	end

end

