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
		item_type = item.xpath('//table[@class="border"]/tr/td/p/font').first.text
	end
end

item.xpath('//table[@class="border"]/tr/td > td/font[@size="5"]').text


binding.pry

print ""



# - councillor_id (member motion)
# - summary
# - recommendation
# - decision_text
# - background information 
# - ward

