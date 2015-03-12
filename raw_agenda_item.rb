class RawAgendaItem
	def self.parse(item_number, item)
		item_type   = item.xpath("#{SECTION_HEADER_TABLE}/p/font").first.text.capitalize.chop
		ward        = item.xpath("#{SECTION_HEADER_TABLE}/p/font").last.text.chop
		item_title  = item.xpath('//table/tr/td/font/b').first.text
		item_tables = item.xpath('//table')
		raw_html    = item.xpath('//table')[2..item_tables.length]	
		new(number: item_number, type: item_type, ward: ward, title: item_title, contents: raw_html)
	end

	def initialize(number: nil, type: nil, ward: nil, title: nil, contents: nil)
		@number   = number
		@type     = type
		@ward     = ward
		@title    = title
		@contents = contents.css('td').map do |node|
			if node.css('p').length > 0
				node.css('p')#.map(&:text)
			else
				node.css('b')
			end
		end.flatten
		@recommendations = separate_recs_and_text(contents)
		@supplementary_text
	end

	def separate_recs_and_text(contents)
		# if type == ACTION && node.matches?("b") && node.contains("Recommendations")
		# 	then we want to save the data after that
		# if node.matches?("b") && !node.contains("Recommendations")
		# 	then we want save from here to the end of the item as html

		sections = contents.select { |e| e.name = "b" }

		sections.each do |section|
			if section.css("b").text == "Recommendations"
				@recommendations = section.css("p")
			end
		end
	end
		# key_words = [
		# 	"Recommendations",
		# 	"Decision Advice and Other Information",
		# 	"Origin",
		# 	"Summary",
		# 	"Background Information",
		# 	"Speakers",
		# 	"Communications",
		# 	"Declared Interests"
		# 	]

	def to_s
		[
			"Number: #{@number}",
			"Title: #{@title}",
			"Ward: #{@ward}",
			"Type: #{@type}",
			"Recommendations: #{@recommendations}",
			"-------",
			@contents.join("\n")
		].join("\n")
	end
end