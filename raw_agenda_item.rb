class RawAgendaItem
	def self.parse(item_number, item)
		item_type   = item.xpath("//table[@class='border']/tr/td/p/font").first.text.capitalize.chop
		ward        = item.xpath("//table[@class='border']/tr/td/p/font").last.text.chop
		item_title  = item.xpath('//table/tr/td/font/b').first.text
		item_tables = item.xpath('//table')
		raw_html    = item.xpath('//table')[2..item_tables.length]	
		new(number: item_number, type: item_type, ward: ward, title: item_title, contents: raw_html)
	end

	def initialize(number: nil, type: nil, ward: nil, title: nil, contents: nil)
		@number 	= number
		@type 		= type
		@ward 		= ward
		@title 		= title
		
		keywords = [
			"Recommendations",
			"Decision Advice and Other Information",
			"Origin",
			"Summary",
			"Background Information",
			"Speakers",
			"Communications",
			"Declared Interests"
		]

		sections = Hash.new('')
		current_section = ""

		@contents = contents.css('td').map do |node|
			if node.css('p').length > 0
				sections[current_section] << node.css('p').map(&:text).join(" ")
			elsif node.css('b').length > 0 && keywords.any? { |keyword| node.text[keyword] }
				current_section = node.text
				sections[current_section] = ""
			else
				sections[current_section] << node.to_s
			end
		end.flatten
	end

	def to_s
		[
			"Number: #{@number}",
			"Title: #{@title}",
			"Ward: #{@ward}",
			"Type: #{@type}",
			"-------",
			@contents.join("\n")
		].join("\n")
	end
end