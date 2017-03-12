class User < ActiveRecord::Base
	serialize :profile
	has_many :favorites
	has_many :requests
	
	def self.filter_by_user_month_creation dayNumber
        where("created_at < ?", Time.now - dayNumber.day)
	end
end
