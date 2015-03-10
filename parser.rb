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
		
		if item_number.start_with? "MM"
			member_motion = item.xpath('//table/tr/td/font/b').first.text
		puts "#{item_number} #{member_motion}" 	
			member_motion = item.xpath('//table/tr/td/font/b')[1].text if member_motion.start_with? "Member Motions"
			by = member_motion.split(" - by ")
			councillor = by[1].split(", seconded by ")
# binding.pry if item_number == "MM3.1"
			# binding.pry if item_number == "MM3.35"
		end
	end
end

binding.pry

print ""



# - councillor_id (member motion)


# - summary
# - recommendation
# - decision_text
# - background information 

