class Request < ActiveRecord::Base
	belongs_to :user

	def self.filter_by_request_month_creation dayNumber
        where("created_at < ?", Time.now - dayNumber.day)
	end
end
