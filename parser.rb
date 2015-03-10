require "nokogiri"
require	"awesome_print"
require "pry"

file = File.open("agendas/9688.html").read
sections = file.scrub.split("<br clear=\"all\">")

preview = sections.map do |section|
	"<div style=\"border: 2px solid red; margin-bottom: 50px\">#{section}</div>"
end.join

File.open("preview.html", 'w') {|f| f.write(preview) }

items = sections.map { |item| Nokogiri::HTML(item) }

items.each do |item|
	item_number = item.xpath('//table[@class="border"]/tr/td/font[@size="5"]').text
	unless item_number.empty?
		item_type = item.xpath('//table[@class="border"]/tr/td/p/font').first.text.capitalize.chop
		ward = item.xpath('//table[@class="border"]/tr/td/p/font').last.text.chop
		item_title = item.xpath('//table/tr/td/font/b').first.text
		item_tables = item.xpath('//table')
		raw_html = item.xpath('//table')[2..item_tables.length]
		binding.pry if item_number == "IA3.3"
	end
end



print ""



# - councillor_id (member motion)
# - summary
# - recommendation
# - decision_text
# - background information 

