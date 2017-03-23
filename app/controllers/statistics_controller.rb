class StatisticsController < ApplicationController

	def stats
		@user_count_month_array = get_user_count_month_array 1
		@request_count_month_array = get_request_count_month_array 1
		@all_stops = get_all_stops_array
	end

	def refresh_user_chart 
      graph_data = get_user_count_month_array params[:value].to_i
      render json: {graph_data: graph_data} 
	end

	def refresh_request_chart 
      graph_data = get_request_count_month_array params[:value].to_i
      render json: {graph_data: graph_data} 
	end

	def stop_analysis
		bus_stop_data = get_bus_stop_data params[:value].to_i
		render json: {graph_data: bus_stop_data}
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

	def get_all_stops_array
		Request.uniq.pluck(:stop_id)
	end

	def get_bus_stop_data (stop_id)
		request_array = Request.where(stop_id: stop_id).pluck(:line_id)
		colors = ['#B23830', '#F3FF89', '#3E86CC', '#FF7970']
		output = {}
		output[:categories] = request_array.uniq
		output[:data] = []
		output[:categories].each do |bus_id| 
			output[:data].push({
				name: bus_id,
				color: colors.delete(colors.sample),
				y: request_array.count(bus_id)
			})
		end
		return output
	end
end
