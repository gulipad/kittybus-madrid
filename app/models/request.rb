class Request < ActiveRecord::Base
	belongs_to :user

	def self.filter_by_request_month_creation dayNumber
        where("created_at < ?", Time.now - dayNumber.day)
	end

	def self.filter_last_twenty_minutes
		where("created_at > ?", Time.now - 0.33.hour)
	end
end
