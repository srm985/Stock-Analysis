require 'open-uri'
require 'csv'
require 'green_shoes'

temp_arr = Array.new
stock_pick_output = Array.new

#*****Pick Stock_List.csv*****
target_location = ask_open_file("")
company_list = CSV.read(target_location)

puts "Reading..."

puts "Transposing..."

l = company_list.map(&:length).max
output_arr = company_list.map{|e| e.values_at(0...l)}.transpose

puts "Analyzing..."

output_arr.each do |temp_comp|
	history_length = temp_comp.length
	positive = 0
	negative = 0
	positive_short = 0
	negative_short = 0
	positive_safety = 0
	negative_safety = 0
	trade_returns = 0
	past_week_return = 0
	abs_low = [9999.9, 0, false]
	stock_average = 0
	recent_stock_average = 0
	recent_performance_increase = false


	for i in 1...history_length
		if (i + 4 < history_length)
			if (temp_comp[i].to_f / temp_comp[i + 4].to_f >= 1.05)
				positive += 1
			elsif (temp_comp[i].to_f / temp_comp[i + 4].to_f < 1)
				negative += 1
			end
		end
		if (i + 4 < history_length) && (i <= temp_comp.length / 4)
			if (temp_comp[i].to_f / temp_comp[i + 4].to_f >= 1.05)
				positive_short += 1
			elsif (temp_comp[i].to_f / temp_comp[i + 4].to_f < 1)
				negative_short += 1
			end
		end
		if (i + 4 < history_length)
			if (temp_comp[i].to_f / temp_comp[i + 4].to_f >= 1)
				positive_safety += 1
			elsif (temp_comp[i].to_f / temp_comp[i + 4].to_f < 1)
				negative_safety += 1
			end
		end
		if (i + 1 < history_length) && (i <= temp_comp.length / 4)
			trade_returns += temp_comp[i].to_f / temp_comp[i + 1].to_f
		end
		if (temp_comp[i].to_f < abs_low[0].to_f)
			abs_low[0] = temp_comp[i].to_f
			abs_low[1] = i
		end
	end

	if (abs_low[1] <= 10)
		abs_low[2] = true 
	end

	if (history_length >= 5)
		past_week_return = temp_comp[1].to_f / temp_comp[5].to_f
	end

	
	if (positive_safety > 0)
		temp_arr = Array.new
		temp_arr[0] = temp_comp[0]
		temp_arr[1] = positive
		temp_arr[2] = negative
		temp_arr[3] = positive.to_f / negative.to_f rescue temp_arr[3] = 0
		temp_arr[4] = positive_short
		temp_arr[5] = negative_short
		temp_arr[6] = positive_short.to_f / negative_short.to_f rescue temp_arr[6] = 0
		temp_arr[7] = (temp_arr[3] + temp_arr[6]) / 2 rescue temp_arr[7] = 0
		temp_arr[8] = positive_safety
		temp_arr[9] = negative_safety
		temp_arr[10] = positive_safety.to_f / negative_safety.to_f rescue temp_arr[10] = 0
		temp_arr[11] = (temp_arr[7] + temp_arr[10]) / 2 rescue temp_arr[11] = 0
		temp_arr[12] = trade_returns.to_f / (temp_comp.length / 4).to_f
		temp_arr[13] = past_week_return.to_f
		temp_arr[14] = abs_low[2]


		stock_pick_output << temp_arr
	end
end

stock_pick_output.unshift(["Stock:", "5% Long:", "Negative Long", "Return Ratio Long:", "5% Short:", "Negative Short", "Return Ratio Short:", "Long/Short Weight:", "Positive Safety:", "Negative Safety:", "Safety Ratio:", "Score:", "Trade Returns:", "Previous Week Return:", "Slump:"])

puts "Writing..."

target_location.slice! "Stock_List.csv"

CSV.open(target_location + 'Stock_Picks.csv', 'w') do |csv| 
  stock_pick_output.each do |row| 
    csv << row
  end
end
