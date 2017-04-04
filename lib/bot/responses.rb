class Responses
	def self.reset
		[	
			"Oh, perdona si me quedé atascado. Ya debería estar recuperado :smiley_cat:",
			"Oooops me quedé atascado. Ya debería estar recuperado :heart_eyes_cat:",
			"Sorry, un lapsus, ya deberia estar funcionando de nuevo! :smile_cat:",

		].sample
	end

	def self.location_request
		[	
			"Genial, dale al botón para enviarme tu ubicación",
			"Sin problemas, mándame tu ubicación con el botón",
			"Guay! Dale al botón para pasarme tu ubicación",

		].sample
	end

	def self.main_greeting
		[	
			":cat: Miau! Hola %s! Yo soy KittyBus!",
			":cat: Miau! Hellou %s! Me llamo KittyBus!",
			":cat: Miau! Que tal %s? Yo soy KittyBus!",

		].sample
	end

	def self.tutorial_query
		[	
			"Me conoces ya o necesitas que te cuente lo que hago? :heart_eyes_cat:",
			"Quieres saber lo que sé hacer o ya me conoces? :heart_eyes_cat:",
			"Sabes ya lo que sé hacer o quieres que te lo diga? :heart_eyes_cat:",

		].sample
	end

	def self.onboarding
		{
			stop_code: "Puedes darme un código de parada, y te digo cuánto le queda al bus",
			save_stop: "Y puedes guardar paradas en tus favoritos para que no se te olviden!",
			close_stops: "También puedes preguntar por paradas cercanas cuando quieras!:heart_eyes_cat:",
			help: "Y por ultimooo... si en cualquier momento tienes alguna duda, pudes escribir AYUDA así en mayúsculas y te digo todo lo que sé hacer. Miau! :smile_cat:"
		}
	end

	def self.no_tutorial
		[	
			"Okey %s, pues aqui estoy para lo que me necesites :smiley_cat:",
			"Vale %s, pues estoy escuchando! :smiley_cat:",
			"Genial %s, pues si me necesitas aqui estoy :heart_eyes_cat:"

		].sample
	end

	def self.tutorial_fail
		[	
			"Oooh estaba en modo tutorial y no he captado eso. Ahora sí que estoy listo. Si en algún momento dudas, puedes poner AYUDA así en mayúsculas.",
			"En modo tutorial solo entiendo botones jeje. Si necesitas ayuda puedes poner AYUDA y te lo repito todo :smiley_cat:",
			"Me he hecho un lío, en modo tutorial solo entiendo botones. Puedes poner AYUDA si quieres que te lo repita, o darme un código de parada! :smiley_cat:"

		].sample
	end

	def self.get_route
		[	
			"Sorry, no te sé decir cómo llegar a un sitio a partir de una dirección. Necesito un código de parada. Miau! :smile_cat:",
			"Creo que quieres que te digas como llegar a un sitio a partir de una dirección. Todavía no se hacer eso. Necesito un código de parada. Miau! :smiley_cat:",
			"Jo, todavía no se dar cómo llegar a un sitio a partir de donde estas. Necesito tu código de parada. :crying_cat_face:"

		].sample
	end

	def self.insult_gif
		[
			'http://i.giphy.com/l3q2SaisWTeZnV9wk.gif',
			'http://i.giphy.com/3rg3vxFMGGymk.gif'

		].sample
	end

	def self.stop
		 [
		 	"Lo tengo! :smile_cat: Parada %s - %s",
		 	"Genial! :heart_eyes_cat: Parada %s - %s",
		 	"Guay! :smile_cat: Parada %s - %s"

		 ].sample
	end

	def self.buses
		[
			"Tengo datos de estos buses!",
			"Me dicen que pasan estos buses!:smile_cat:",
			"Ahora hay datos de estos buses :smiley_cat:"

		].sample
	end

	def self.no_buses
		[
			":cat: Oooops. No tengo datos de esta parada. Es posible que no haya autobuses a esta hora.:crying_cat_face:",
			":cat: Vaya! No me llegan datos de esta parada. Es posible que no pasen más a esta hora.:crying_cat_face:",
			":cat: Oooops. No tengo datos de esta parada. Es posible que no haya autobuses a esta hora.:crying_cat_face:"

		].sample
	end

	def self.failure
		[	
			":cat: Creo que me he perdido (soy un poco tonto a veces :crying_cat_face:). Recuerda que puedes escribir AYUDA en cualquier momento!",
			":crying_cat_face: Oooh, no he entendido eso. Puedes escribir AYUDA cuando quieras si tienes alguna duda!",
			":crying_cat_face: JO, no he entendido eso. Puedes escribir AYUDA cuando quieras si tienes alguna duda!"
		
		].sample
	end

	def self.output
		[
			"Okey, aqui tienes %s! :smiley_cat:",
			"Here you go %s! :smile_cat:",
			"Fenomenal %s! :smile_cat:"

		].sample
	end

	def self.emojis
		[	
			":heart_eyes_cat::heart_eyes_cat:",
			":smiley_cat::smiley_cat:",
			":smile_cat::heart_eyes_cat::smiley_cat:"
			].sample
	end

	def self.last_bus
		[
			":cat:Miau! El bus %s.  No tengo más datos, es muy posible que sea el último del día!",
			":cat:Miau! Tu bus %s.  Creo que no vienen más hoy :crying_cat_face:",
			":cat:Miau! El bus %s.  Es posible que ya no vengan más hoy, porque no tengo más datos"

		].sample
	end

	def self.bus_times
		[	
			"El primer bus %s, y el siguiente %s. :cat: Miau! ",
			"Ok! :cat: Tu primer bus %s, y hay otro que %s."

		].sample	
	end

	def self.nice_day
		[
			"Buen viaje #{@first_name}!",
			"Estoy aqui cuando quieras!:heart_eyes_cat:",
			"Ten un viaje estupendo! :cat:"
		].sample
	end

	def self.previous_requests
		[
			"Me han pedido ese bus %s veces en los últimos 20 minutos. Asi que ojico, que igual va petao :scream_cat:",
			"En los últimos 20 minutos me han pedido ese bus %s veces. Igual va un poco lleno!",
			"Me han pedido ese bus %s veces en 20 minutos. Quizás haya mucha gente! :scream_cat:"
		].sample
	end

	def self.no_data_bus
		[
			"No tengo datos de ese bus, sorry. :crying_cat_face:",
			"No me han dicho tiempos para ese bus, lo siento. :crying_cat_face:",
			":crying_cat_face: Lo siento, no se nada de ese bus."
		].sample
	end

	def self.fail_bus
		[
			"No he entendido eso. No he captado línea de bus. Pídeme la parada de nuevo! :cat:",
			"Eso creo que no ha sido una línea de bus. Volvamos a empezar, dame el código de parada! :smile_cat:",
			"Hmmm no te he entendido. Necesito una línea de bus. Volvamos a empezar :cat:"

		].sample
	end
end

