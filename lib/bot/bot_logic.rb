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

		ENV["DOMAIN_NAME"] = "https://a27d512c.ngrok.io"

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
		stop_id = get_message
		if stop_id.match(/gr{1,}a{1,}ci{1,}a{1,}s{1,}|gra{1,}zie{1,}|thank|thx|thnks/i)
			reply_message ":smiley_cat: No hay de que! Aquí estoy cuando quieras. Miau!"
		elsif stop_id.match(/ho{1,}la{1,}|o{1,}la{1,}|he{1,}llo{1,}/i)
			reply_message ":heart_eyes_cat: Hola hola! Código de parada por favor. Miau!"
		else stop_id = get_message.gsub(/[^0-9]/,"")
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
	end

	def self.get_bus_times
		regexp = get_message[/(n|m|t|h|e|c)\d{1,}|\d{1,}|(\s|^)(U|H|F|G|A)(\s|$)/i]
		bus_id = (regexp) ? regexp.strip : ""
		puts bus_id
		if bus_id != ""	
			times = get_times(bus_id)
			if times != "not_included"
				if times.length == 1
					reply_message ":cat:Miau! El bus #{times[0]}.  Es el último del día!"
					state_go 1
				else
					reply_message ["El primer bus #{times[0]}, y el siguiente #{times[1]}. :cat: Miau! ", "Ok! :cat: Tu primer bus #{times[0]}, y hay otro que #{times[1]}."].sample
					reply_message ["Buen viaje!", "Estoy aqui cuando quieras!:heart_eyes_cat:", "Ten un viaje estupendo! :cat:"].sample
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
end

