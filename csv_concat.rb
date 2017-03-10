require 'csv'
require 'green_shoes'

stock_arr = Array.new
holding_arr = Array.new
output_arr = Array.new

stock_name_arr = Array.new

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
		stock_name_arr << temp_file
		stock_arr << temp_stock['Close']
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