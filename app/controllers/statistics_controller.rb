class StatisticsController < ApplicationController

	def stats
		@user_count_month_array = get_user_count_month_array 10
		@request_count_month_array = get_request_count_month_array 10
	end

	def refresh_user_chart 
      graph_data = get_user_count_month_array params[:value].to_i
      render json: {graph_data: graph_data} 
	end

	private

	def get_user_count_month_array monthNumber
		array = []
		(monthNumber).times do |index|
			array.push(
				{
					users: User.filter_by_user_month_creation(index).count, 
					month: (Time.now() - index.month).strftime("%B")
				})
		end
		array.reverse
	end

	def get_request_count_month_array monthNumber
		array = []
		(monthNumber).times do |index|
			array.push(
				{
					requests: Request.filter_by_request_month_creation(index).count, 
					month: (Time.now() - index.month).strftime("%B")
				})
		end
		array.reverse
	end
end
