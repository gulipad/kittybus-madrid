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

		ENV["DOMAIN_NAME"] = "https://a9b321d4.ngrok.io"
		@first_name = get_profile(@current_user.fb_id)["first_name"]

		if @request_type == "CALLBACK"
      		case @fb_params.payload
      			when "RESET_BOT"
	        		@current_user.delete
	        		reply_message "Removed all your data from our servers."
        		return
        		when "bot_start_payload"
        		reply_message ":cat: Miau! Hola #{@first_name}! Soy KittyBus, te digo cuánto le queda al bus!"
        		reply_message "Puedes darme un código de parada, o preguntar por paradas cercanas cuando quieras!:heart_eyes_cat:"
        		state_go 1
        		return
        		
      	end
    end
    	state_action 0, :greet
		state_action 1, :convo_root
		state_action 2, :get_bus_times
		state_action 3, :handle_location
	end

	def self.greet
        state_go 
	end

	def self.convo_root
		@stop_id = get_message
		ai_response = ai_response(@stop_id)
		if @stop_id[/GUARDAR {0,5}/]
			stop_id = @stop_id.gsub('GUARDAR ', '')
			User.find_by(id: @current_user.id).favorites.find_by(stop_id: stop_id) ? reject_save_location : save_location(stop_id)
		elsif @stop_id[/BORRAR {0,5}/]
			stop_id = @stop_id.gsub('BORRAR ', '')
			User.find_by(id: @current_user.id).favorites.find_by(stop_id: stop_id) ? delete_location(stop_id) : reject_delete_location
		elsif ai_response[:result][:metadata][:intentName] == 'thanks' 
			typing_indicator
			reply_message ":smiley_cat: No hay de que! Aquí estoy cuando quieras. Miau!"
		elsif ai_response[:result][:metadata][:intentName] == 'greeting'
			typing_indicator
			ai_reply = sprintf(ai_response[:result][:fulfillment][:speech].to_s, @first_name)
			reply_message ai_reply
		elsif ai_response[:result][:metadata][:intentName] == 'insultDefense'
			typing_indicator
			ai_reply = sprintf(ai_response[:result][:fulfillment][:speech].to_s, @first_name)
			reply_image ['http://i.giphy.com/l3q2SaisWTeZnV9wk.gif', 'http://i.giphy.com/3rg3vxFMGGymk.gif'].sample
			reply_message ai_response[:result][:fulfillment][:speech]
		elsif ai_response[:result][:metadata][:intentName] == 'favorites'
			typing_indicator
			handle_favorites(ai_response[:result][:parameters])
		elsif ai_response[:result][:metadata][:intentName] == 'locationRequest'
			typing_indicator
			reply_location_button("Para eso necesito tu localización")
			state_go 3
		else @stop_id = get_message.gsub(/[^0-9]/,"")
			process_stop
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
					reply_message ["Buen viaje #{@first_name}!", "Estoy aqui cuando quieras!:heart_eyes_cat:", "Ten un viaje estupendo! :cat:"].sample
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
			close_stops = get_close_stops(lat, lng, radius)
			reply_quick_buttons "Aquí tienes #{@first_name}! Las paradas a un radio de 200 metros de tu posición. Miau!", close_stops
			state_go 1
		else
			reply_message "No he captado localización, volvamos a empezar :smiley_cat:. Me das una parada? "
			state_go 1
		end
	end

	## Support functions

	def self.handle_favorites(entities)
		if entities[:save] == '' && entities[:see] == ''
			reply_message 'Para guardar una parada a favoritos, pon GUARDAR seguido del código de parada. Por ejemplo GUARDAR 123 :smiley_cat:'
			reply_message 'Para ver tus favoritos, sólo tienes que pedirmelo! Miau! :heart_eyes_cat:'
		elsif entities[:save] != ''
			reply_message 'Para guardar una parada a favoritos, pon GUARDAR seguido del código de parada. Por ejemplo GUARDAR 123 :smiley_cat:'
		elsif entities[:see] != ''

			if Favorite.where(user_id: @current_user.id).first()
				typing_indicator
				reply_quick_buttons "Aquí tienes #{@first_name}! Tus paradas favoritas. Miau!", Favorite.where(user_id: @current_user.id).pluck(:stop_id) 
			else
				typing_indicator
				reply_message "Sorry, no tienes ninguna parada guardada!:crying_cat_face:"
				reply_message 'Para guardar una parada a favoritos, pon GUARDAR seguido del código de parada. Por ejemplo GUARDAR 123 :smiley_cat:'
			end
		end
	end

	def self.save_location(stop_id)
		Favorite.create(user_id: @current_user.id, stop_id: stop_id)
		reply_message 'Hecho! :smiley_cat:'
		reply_message "Recuerda que puedes borrarla escribiendo BORRAR #{stop_id}"
	end

	def self.reject_save_location
		reply_message 'Sorry, esa parada ya la tienes guardada :smiley_cat:'
		reply_message 'Para ver tus favoritos, sólo tienes que pedirmelo! Miau! :heart_eyes_cat:'
	end

	def self.delete_location(stop_id)
		reply_message "Ok, #{@first_name}! Parada borrada :smiley_cat:"
	end

	def self.reject_delete_location
		reply_message 'Ooops, esta parada no está en tus favoritos :smiley_cat:'
		reply_message 'Para ver tus favoritos, sólo tienes que pedirmelo! Miau! :heart_eyes_cat:'
	end

	def self.process_stop
		if @stop_id != ""
				typing_indicator
				response = get_emt_data(@stop_id)
				if response['errorCode'] != "-1"
					@current_user.profile = {stop_id: @stop_id}
					reply_message  ["Lo tengo! :smiley_cat: Parada #{@stop_id} - #{response['stop']['direction']}", "Genial! :smiley_cat: Parada #{@stop_id} - #{response['stop']['direction']}"].sample
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

	## End support functions

end

