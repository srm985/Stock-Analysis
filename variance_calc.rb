require 'csv'
require 'green_shoes'
require 'descriptive_statistics'

stock_arr = Array.new
holding_arr = Array.new
output_arr = Array.new
stock_name_arr = Array.new

minReturn = 1.05
minTradeVolume = 100000
minTradePrice = 1.50

#*****Pick raw data folder.*****
target_location = ask_open_folder('')
#target_location.slice! 'target.txt'
target_location = target_location + '\\'

puts 'Compiling...'

Dir.foreach(target_location) do |temp_file|
	if temp_file.include? '.csv'
		
		temp_stock = CSV.read(target_location + temp_file, :headers=>true)
		temp_file.slice! '_'
		temp_file.slice! '.csv'
		
		#absoluteLow = temp_stock['Low'].sort.detect{ |x| x.to_f > 0 }
		#absoluteHigh = temp_stock['High'].sort.last

		#puts 'low: ' + absoluteLow.to_s + ' high: ' + absoluteHigh.to_s

		holding_arr.clear
		holding_arr[0] = (temp_stock['High'].zip(temp_stock['Low']).map{ |x, y| x.to_f / y.to_f}).mean

		tempArr = temp_stock['High'].zip(temp_stock['Low']).map{ |x, y| y.to_f > 0 ? x.to_f / y.to_f : 0 }
		absoluteLow = tempArr.sort.detect{ |x| x.to_f > 0 }
		absoluteHigh = tempArr.sort.last
		tempArr = tempArr.map { |x| (absoluteHigh - absoluteLow == 0 || x.to_f - absoluteLow == 0) ? 0 : (x.to_f - absoluteLow) / (absoluteHigh - absoluteLow) }

		#holding_arr[1] = (temp_stock['High'].zip(temp_stock['Low']).map{ |x, y| x.to_f / y.to_f}).standard_deviation
		holding_arr[1] = tempArr.standard_deviation
		
		holding_arr[2] = temp_stock['Volume'].mean
		tradingPrice = temp_stock['Low'].mean
		holding_arr.map!{ |x| x == nil ? 0 : x}
		if (holding_arr[0] >= minReturn && holding_arr[2] >= minTradeVolume && tradingPrice >= minTradePrice)
			stock_arr << holding_arr.dup
			stock_name_arr << temp_file	#Only write stock name to file if it passes my checks.
		end
	end
end

puts 'Transposing...'
l = stock_arr.map(&:length).max
output_arr = stock_arr.map{|e| e.values_at(0...l)}.transpose
output_arr.unshift(stock_name_arr)

puts 'Writing...'
target_location.slice! 'Raw_Data\\'
target_location = target_location + 'Analysis\\'

CSV.open(target_location + 'Stock_List.csv', 'w') do |csv| 
  output_arr.each do |row| 
    csv << row
  end
end