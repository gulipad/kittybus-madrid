
class BotLogic < BaseBotLogic	
	
	def self.setup
		set_welcome_message "Hola, soy Kitty! Te ayudo a saber cuánto le queda al bus en Madrid."
		set_get_started_button "bot_start_payload"
		set_bot_menu ['Ayuda','Ver Favoritos', 'Paradas Cercanas','Resetear Bot']
	end

	def self.cron
		broadcast_all ":princess:"
	end

	def self.bot_logic

		@first_name = get_profile(@current_user.fb_id)["first_name"]

		if @request_type == "CALLBACK"
      		case @fb_params.payload
      			when "RESETEAR_BOT_BOT"
	        		reply_message Responses.reset
	        		state_go 1
        		return
        		when "AYUDA_BOT"
        			list_instructions
        		return 
        		when "PARADAS_CERCANAS_BOT"
        			reply_location_button(Responses.location_request)
					state_go 3
        		return 
        		when "VER_FAVORITOS_BOT"
        			view_favorites
        		return
        		when "bot_start_payload"
        			reply_message Responses.main_greeting % @first_name
        			reply_quick_reply Responses.tutorial_query, ['Dímelo porfa!', 'Ya te conozco']
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
		case onboarding
		when "Dímelo porfa!"
			typing_indicator   
			reply_message Responses.onboarding[:stop_code]
			sleep(1)
        	reply_quick_reply Responses.onboarding[:save_stop], ["Entendido"]
        when "Entendido"
        	reply_message Responses.onboarding[:close_stops]
			reply_message Responses.onboarding[:help]
        	state_go 
		when "Ya te conozco"
			reply_message Responses.no_tutorial % @first_name
        	state_go 
		else
			reply_message Responses.tutorial_fail
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

		if @user_says[/GUARDAR \d{0,5}/i] && @user_says.downcase[/GUARDAR \d{0,5}/i] != "guardar "
			stop_id = @user_says.gsub(/GUARDAR/i, '')
			User.find_by(id: @current_user.id).favorites.find_by(stop_id: stop_id) ? reject_save_location : save_location(stop_id)
		elsif @user_says[/BORRAR \d{0,5}/i]
			stop_id = @user_says.gsub(/BORRAR/i, '')
			User.find_by(id: @current_user.id).favorites.find_by(stop_id: stop_id) ? delete_location(stop_id) : reject_delete_location
		elsif ai_intent == 'help'
			list_instructions
		elsif ai_intent == 'getRoute' && ai_score > 0.8
			reply_message Responses.get_route
			# @destination_address = ai_response[:result][:parameters][:address]
			# reply_location_button("Para eso necesito tu ubicación")
			# state_go 4
		elsif ai_intent == 'thanks' || ai_intent == 'greeting' || ai_intent == 'farewell' || ai_intent == 'agreement' || ai_intent == 'insultDefense' && ai_score > 0.9
			ai_reply = ai_reply % @first_name
			if ai_intent == 'insultDefense'
			  reply_image Responses.insult_gif
			end
			reply_message ai_reply
		elsif ai_intent == 'favorites'
			handle_favorites(ai_response[:result][:parameters])
		elsif ai_intent == 'locationRequest' && ai_score > 0.8
			reply_location_button Responses.location_request 
			state_go 3
		else
			@user_says = get_message[/\d+/i]
			process_stop
		end	
		typing_off	
	end

	def self.process_stop
		typing_indicator
		if @user_says
			typing_indicator
			response = get_emt_data(@user_says)
			puts response
			if response['errorCode'] != "-1"
				reply_message Responses.stop % [@user_says, response['stop']['direction']]
				@stop_id = @user_says
				@bus_lines = get_lines(response)
				if @bus_lines.length > 1
					@bus_lines.push('Todos')
				end
				reply_quick_reply Responses.buses, @bus_lines
				state_go
			else 
				reply_message Responses.no_buses
			end	
		else
			reply_message Responses.failure

		end
		typing_off
	end

	def self.get_bus_times
		typing_indicator
		if get_message[/todos/i]
			reply_message Responses.output % @first_name
			reply_message get_all_times
			reply_message Responses.emojis
			state_go 1
		else
			regexp = get_message[/(n|m|t|h|e|c)\d{1,}|\d{1,}|(\s|^)(U|H|F|G|A)(\s|$)/i]
			line_id = (regexp) ? regexp.strip : ""
			if line_id != ""	
				times = get_times(line_id)
				if times
					Request.create(user_id: @current_user.id, stop_id: @stop_id, line_id: line_id)
					previousRequests = Request.filter_last_twenty_minutes.where(line_id: line_id).count
					if times.length == 1
						reply_message Responses.last_bus % times[0]
						state_go 1
					else
						reply_message Responses.bus_times % [times[0], times[1]]
						reply_message Responses.nice_day % @first_name
						state_go 1
					end
					if previousRequests > 3
						reply_message Responses.previous_requests % previousRequests
					end
					typing_off
				else
					reply_message Responses.no_data_bus
					reply_quick_reply "Tengo estos", @bus_lines
				end
			else 
				reply_message Responses.fail_bus 
				state_go 1
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
			view_favorites
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

	def self.list_instructions
		typing_indicator
		reply_message "Veo que tienes alguna duda, no te preocupes, estoy aquí para ayudar! :smile_cat:"
		reply_message "Esto es todo lo que sé hacer!"
		typing_indicator
		sleep(2)
		reply_message "Si me das un código de parada, yo te digo que autobuses pasan por ahí y cuánto les queda para llegar! :smiley_cat:"
		typing_indicator
		sleep(1)
		typing_indicator
		reply_message "Si me lo preguntas, te digo qué paradas tienes alrededor! "
		sleep(1)
		typing_indicator
		reply_message "Si quieres guardar paradas en tus favoritos, dime GUARDAR y el código de parada. (i.e. GUARDAR 123)."
		reply_message "Y eso es todo amigos! Miau! :kissing_cat:"
		typing_off
	end

	def self.view_favorites
		if Favorite.where(user_id: @current_user.id).first()
			reply_quick_buttons "Aquí tienes #{@first_name}! Tus paradas favoritas. Miau!", Favorite.where(user_id: @current_user.id).pluck(:stop_id) 
		else
			reply_message "Sorry, no tienes ninguna parada guardada!:crying_cat_face:"
			reply_message 'Para guardar una parada a favoritos, pon GUARDAR seguido del código de parada. Por ejemplo GUARDAR 123 :smiley_cat:'
		end
	end

	## End support functions

end

