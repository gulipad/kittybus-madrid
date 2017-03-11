class Request < ActiveRecord::Base
	belongs_to :user

	def self.filter_by_request_month_creation monthNumber
        where("created_at < ?", Time.now - monthNumber.month)
	end
end
