require 'open-uri'
require 'net/http'
require 'csv'
require 'green_shoes'

#*****Pick companylist.csv*****
company_list_location = ask_open_file('')
company_list = CSV.read(company_list_location)

company_list_location.slice! 'companylist.csv'

new_arr = Array.new

company_list.each do |temp_row|
	if temp_row[0].match(/\A[[:alpha:]]+\z/)
		new_arr << temp_row[0]
	end
end

new_arr.shift

i = 1

if company_list_location.include? 'NYSE'
	new_arr.each do |temp|
		download = open('http://www.google.com/finance/historical?q=NYSE%3A' + temp + '&output=csv') rescue download = open('http://www.google.com/finance/historical?q=NYSE%3ABPT&output=csv')
		IO.copy_stream(download, company_list_location.to_s + 'Raw_Data\\' + '_' + temp.to_s + '.csv')
		puts temp.to_s + ': ' + i.to_s + '/' + new_arr.length.to_s
		i += 1
		sleep 0.25
	end
elsif company_list_location.include? 'NASDAQ'
	new_arr.each do |temp|
		download = open('http://www.google.com/finance/historical?q=NASDAQ%3A' + temp + '&output=csv') rescue download = open('http://www.google.com/finance/historical?q=NASDAQ%3AGOOG&output=csv')
		IO.copy_stream(download, company_list_location.to_s + 'Raw_Data\\' + '_' + temp.to_s + '.csv')
		puts temp.to_s + ': ' + i.to_s + '/' + new_arr.length.to_s
		i += 1
		sleep 0.25
	end
end






#download = open('http://www.google.com/finance/historical?q=NASDAQ%3AGOOG&ei=qz2KWImhAoezjAGq06y4BQ&output=csv')
#IO.copy_stream(download, 'temp.csv')