class StatisticsController < ApplicationController

	def stats
		@user_count_month_array = get_user_count_month_array 6
		@request_count_month_array = get_request_count_month_array 6
	end

	def refresh_user_chart 
      graph_data = get_user_count_month_array params[:value].to_i
      render json: {graph_data: graph_data} 
	end

	def refresh_request_chart 
      graph_data = get_request_count_month_array params[:value].to_i
      render json: {graph_data: graph_data} 
	end

	private

	def get_user_count_month_array monthNumber
		array = []
		(monthNumber * 30).times do |index|
			array.push(
				{
					value: User.filter_by_user_month_creation(index).count, 
					date: (Time.now() - index.day)
				})
		end
		array.reverse
	end

	def get_request_count_month_array monthNumber
		array = []
		(monthNumber * 30).times do |index|
			array.push(
				{
					value: Request.filter_by_request_month_creation(index).count, 
					date: (Time.now() - index.day)
				})
		end
		array.reverse
	end
end
