# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

200.times do
	User.create(
		fb_id: 0000000000000000, 
		last_message_received: Time.now()-rand(0..5760).minute, 
		created_at: Time.now()-rand(0..65).day, 
		profile: nil
	)
end

