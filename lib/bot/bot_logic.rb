class BotLogic < BaseBotLogic
	
	def self.setup
		set_welcome_message "Hola, soy KittyBot! Te ayudo a saber cuánto le queda al bus en Madrid."
		set_get_started_button "bot_start_payload"
		set_bot_menu %W(Reset Ayuda)
	end

	def self.cron
		broadcast_all ":princess:"
	end

	def self.bot_logic

		@first_name = get_profile(@current_user.fb_id)["first_name"]

		if @request_type == "CALLBACK"
      		case @fb_params.payload
      			when "RESET_BOT"
	        		@current_user.delete
	        		reply_message "Removed all your data from our servers."
        		return
        		when "AYUDA_BOT"
        			list_instructions
        		return 
        		when "bot_start_payload"
        		reply_message ":cat: Miau! Hola #{@first_name}! Yo soy KittyBus!"
        		reply_quick_reply "Sabes ya lo que se hacer o quieres que te lo diga? :heart_eyes_cat:", ['Dímelo porfa!', 'Ya te conozco']
        		state_go 0
        		return
        		
      	end
    end
    	state_action 0, :greet
		state_action 1, :convo_root
		state_action 2, :get_bus_times
		state_action 3, :handle_location
		state_action 4, :handle_route
	end

	def self.greet
		onboarding = get_message
		puts 'onboarding'
		case onboarding
		when "Dímelo porfa!"
			typing_indicator   
			reply_message "Puedes darme un código de parada, y te digo cuánto le queda al bus"
			sleep(1)
        	reply_quick_reply "Y puedes guardar paradas en tus favoritos para que no se te olviden!", ["Entendido"]
        when "Entendido"
        	reply_message "También puedes preguntar por paradas cercanas cuando quieras!:heart_eyes_cat:"
			reply_message "Y por ultimooo... si en cualquier momento tienes alguna duda, pudes escribir AYUDA así en mayúsculas y te digo todo lo que sé hacer. Miau! :smile_cat:"
        	state_go 
		when "Ya te conozco"
			reply_message "Okey #{@first_name}, pues aqui estoy para lo que me necesites :smiley_cat:"
        	state_go 
		else
			"No he pillao eso, pero da igual, ya estoy listo para lo que necesites. Si en algún momento dudas, puedes poner AYUDA así en mayúsculas."
			state_go
		end
	end

	def self.convo_root
		@user_says = get_message
		typing_indicator
		ai_response = ai_response(@user_says)
		ai_intent = ai_response[:result][:metadata][:intentName]
		ai_reply = ai_response[:result][:fulfillment][:speech].to_s
		ai_score = ai_response[:result][:score]

		if @user_says[/GUARDAR \d{0,5}/i]
			stop_id = @user_says.gsub(/GUARDAR/i, '')
			User.find_by(id: @current_user.id).favorites.find_by(stop_id: stop_id) ? reject_save_location : save_location(stop_id)
		elsif @user_says[/BORRAR \d{0,5}/i]
			stop_id = @user_says.gsub(/BORRAR/i, '')
			User.find_by(id: @current_user.id).favorites.find_by(stop_id: stop_id) ? delete_location(stop_id) : reject_delete_location
		elsif ai_intent == 'help'
			list_instructions
		elsif ai_intent == 'getRoute' && ai_score > 0.8
			@destination_address = ai_response[:result][:parameters][:address]
			reply_location_button("Para eso necesito tu ubicación")
			state_go 4
		elsif ai_intent == 'thanks'
			reply_message ai_reply
		elsif ai_intent == 'greeting'
			ai_reply = sprintf(ai_reply, @first_name)
			reply_message ai_reply
		elsif ai_intent == 'farewell'
			ai_reply = sprintf(ai_reply, @first_name)
			reply_message ai_reply
		elsif ai_intent == 'agreement'
			ai_reply = sprintf(ai_reply, @first_name)
			reply_message ai_reply
		elsif ai_intent == 'insultDefense' && ai_score > 0.9
			ai_reply = sprintf(ai_reply, @first_name)
			reply_image ['http://i.giphy.com/l3q2SaisWTeZnV9wk.gif', 'http://i.giphy.com/3rg3vxFMGGymk.gif'].sample
			reply_message ai_reply
		elsif ai_intent == 'favorites'
			handle_favorites(ai_response[:result][:parameters])
		elsif ai_intent == 'locationRequest' && ai_score > 0.8
			reply_location_button("Para eso necesito tu ubicación")
			state_go 3
		else @user_says = get_message.gsub(/[^0-9]/,"")
			process_stop
		end	
		typing_off	
	end


	def self.get_bus_times
		typing_indicator
		if get_message[/todos/i]
			reply_message ["Okey, aqui tienes :smiley_cat:", "Here you go #{@first_name}! :smile_cat"].sample
			reply_message get_all_times
			reply_message [":heart_eyes_cat::heart_eyes_cat:", ":smiley_cat::smiley_cat:"].sample
			state_go 1
		else
			regexp = get_message[/(n|m|t|h|e|c)\d{1,}|\d{1,}|(\s|^)(U|H|F|G|A)(\s|$)/i]
			bus_id = (regexp) ? regexp.strip : ""
			if bus_id != ""	
				times = get_times(bus_id)
				if times
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
		typing_off
	end

	def self.handle_location
		typing_indicator
		if @request_type == "LOCATION"
			radius = 200
			close_stops = get_close_stops(radius)
			if !close_stops 
				reply_message "Sorry #{@first_name}, no tienes paradas a menos de 200 metros a la redonda. :crying_cat_face:"
				state_go 1
			else
				reply_quick_buttons "Aquí tienes #{@first_name}! Las paradas a un radio de 200 metros de tu posición. Miau!", close_stops
				state_go 1	
			end		
		else
			reply_message "No he captado tu ubicación, si quieres ver paradas a tu alrededor, pídemelo de nuevo! :smiley_cat:. "
			state_go 1
		end
		typing_off
	end

	def self.handle_route
		typing_indicator
		if @request_type == "LOCATION"
			if @destination_address != ""
				route_url = get_route_url(@destination_address)
				if !route_url
					reply_message "Oye, me he liado. No encuentro la dirección de destino. :crying_cat_face:"
					state_go 1
				else
					send_basic_webview_button route_url, 'Aquí tienes tu camino! Cortesía de Google', 'Ver ruta'
					state_go 1
				end
			else
				reply_message "Lo siento #{@first_name}, no he captado dirección de destino. Todavía no se me dan muy bien los sitios, sólo direcciones. Volvamos a empezar. :smiley_cat:"
				state_go 1
			end
		else
			reply_message "No he captado tu ubicación, ahora mismo solo se decirte rutas desde donde estés. Volvamos a empezar :smiley_cat:"
			state_go 1
		end
		typing_off
	end

	## Support functions

	def self.handle_favorites(entities)
		typing_indicator
		if entities[:save] == '' && entities[:see] == ''
			reply_message 'Para guardar una parada a favoritos, pon GUARDAR seguido del código de parada. Por ejemplo GUARDAR 123 :smile_cat:'
			reply_message 'Para ver tus favoritos, sólo tienes que pedirmelo! Miau! :heart_eyes_cat:'
		elsif entities[:save] != ''
			reply_message 'Para guardar una parada a favoritos, pon GUARDAR seguido del código de parada. Por ejemplo GUARDAR 123 :smiley_cat:'
		elsif entities[:see] != ''

			if Favorite.where(user_id: @current_user.id).first()
				reply_quick_buttons "Aquí tienes #{@first_name}! Tus paradas favoritas. Miau!", Favorite.where(user_id: @current_user.id).pluck(:stop_id) 
			else
				typing_indicator
				reply_message "Sorry, no tienes ninguna parada guardada!:crying_cat_face:"
				reply_message 'Para guardar una parada a favoritos, pon GUARDAR seguido del código de parada. Por ejemplo GUARDAR 123 :smiley_cat:'
			end
		end
		typing_off
	end

	def self.save_location(stop_id)
		typing_indicator
		Favorite.create(user_id: @current_user.id, stop_id: stop_id)
		reply_message 'Hecho! :kissing_cat:'
		reply_message "Recuerda que puedes borrarla escribiendo BORRAR #{stop_id}"
		typing_off
	end

	def self.reject_save_location
		typing_indicator
		reply_message 'Sorry, esa parada ya la tienes guardada :smiley_cat:'
		reply_message 'Para ver tus favoritos, sólo tienes que pedirmelo! Miau! :heart_eyes_cat:'
		typing_off
	end

	def self.delete_location(stop_id)
		typing_indicator
		User.find_by(id: @current_user.id).favorites.find_by(stop_id: stop_id).delete()
		reply_message "Ok, #{@first_name}! Parada borrada :smiley_cat:"
		typing_off
	end

	def self.reject_delete_location
		typing_indicator
		reply_message 'Ooops, esta parada no está en tus favoritos :smiley_cat:'
		reply_message 'Para ver tus favoritos, sólo tienes que pedirmelo! Miau! :heart_eyes_cat:'
		typing_off
	end

	def self.process_stop
		typing_indicator
		if @user_says != ""
			typing_indicator
			response = get_emt_data(@user_says)
			if response['errorCode'] != "-1"
				@current_user.profile = {stop_id: @user_says}
				reply_message  ["Lo tengo! :smile_cat: Parada #{@user_says} - #{response['stop']['direction']}", "Genial! :smiley_cat: Parada #{@user_says} - #{response['stop']['direction']}"].sample
				@bus_lines = get_lines(response)
				if @bus_lines.length > 1
					@bus_lines.push('Todos')
				end
				reply_quick_reply "Tengo datos de estos buses!", @bus_lines
				state_go
			else 
				reply_message ":cat: Oooops. No tengo datos de esta parada. Es posible que no haya autobuses a esta hora.:crying_cat_face:"
			end	
		else
			reply_message ":cat: Creo que me he perdido (soy un poco tonto a veces :crying_cat_face:). Recuerda que puedes escribir AYUDA en cualquier momento!"
		end
		typing_off
	end

	def self.list_instructions
		typing_indicator
		reply_message "Veo que tienes alguna duda, no te preocupes, estoy aquí para ayudar! :smile_cat:"
		reply_message "Esto es todo lo que sé hacer!"
		reply_message "Si me das un código de parada, yo te digo que autobuses pasan por ahí y cuánto les queda para llegar! :smiley_cat:"
		reply_message "Si me lo preguntas, te digo qué paradas tienes alrededor! "
		reply_message "Si quieres guardar paradas en tus favoritos, dime GUARDAR y el código de parada. (i.e. GUARDAR 123)."
		reply_message "Y eso es todo amigos! Miau! :kissing_cat:"
		typing_off
	end

	## End support functions

end

