# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

2000.times do
	Request.create(
		user_id: rand(0..505), 
		stop_id: rand(1..9999).to_s, 
		line_id: rand(1..200).to_s, 
		created_at: Time.now()-rand(0..65).day 
	)
end

