require "net/http"
require "nokogiri"
require "open-uri"
require "pry"
require "awesome_print"

base = URI("http://app.toronto.ca/tmmis/meetingCalendarView.do")
SECTION_HEADER_TABLE = "//table[@class='border']/tr/td"

class CityCouncilAgenda
	attr_reader :id
	
	def initialize(id)
		@id = id
	end

	def name
		"#{@id}.html"
	end

	def filename
		"agendas/#{name}"
	end

	def url
		"http://app.toronto.ca/tmmis/viewPublishedReport.do?function=getCouncilAgendaReport&meetingId=#{@id}"
	end

	def content
		@content ||= begin
			if File.exist?(filename)
				open(filename).read
			else
				open(url).read
			end
		end
	end

	def save
	  File.open(filename, 'w') {|f| f.write(content) }
	end
end

class RawAgendaItem
	def self.parse(item_number, item)
		item_type 	= item.xpath("#{SECTION_HEADER_TABLE}/p/font").first.text.capitalize.chop
		ward 				= item.xpath("#{SECTION_HEADER_TABLE}/p/font").last.text.chop
		item_title 	= item.xpath('//table/tr/td/font/b').first.text
		item_tables = item.xpath('//table')
		raw_html 		= item.xpath('//table')[2..item_tables.length]	
		new(number: item_number, type: item_type, ward: ward, title: item_title, contents: raw_html)
	end

	def initialize(number: nil, type: nil, ward: nil, title: nil, contents: nil)
		@number 	= number
		@type 		= type
		@ward 		= ward
		@title 		= title
		@contents = contents.css('td').map do |node|
			if node.css('p').length > 0
				node.css('p').map(&:text)
			else
				node.text
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

	def save
		puts to_s
		puts "----------------"
	end
end

def report_params(month, year)
  {
    function:        "meetingCalendarView",
    isToday:         "false",
    expand:          "N",
    view:            "List",
    selectedMonth:   month,
    selectedYear:    year,
    includeAll:      "on"
  }
end

calendar_page = Net::HTTP.post_form(base, report_params(1, 2015)).body

page = Nokogiri::HTML(calendar_page)

meeting_links = page.css("#calendarList .list-item a").map do |anchor| 
  anchor.attr('href') if anchor.text.include? "City Council"
end.reject(&:nil?).uniq

council_agendas = meeting_links.map do |meeting_link|
	puts "Checking #{meeting_link}"
  site = "http://app.toronto.ca" + meeting_link
  agenda_list = Nokogiri::HTML(open(site))

  agenda_ids = agenda_list.css("#accordion h3").map do |x| 
    x.attr('id').gsub("header", "")
  end.uniq

  agenda_ids.map do |id|
  	CityCouncilAgenda.new(id)
  end
end.flatten

# council_agendas.each do |agenda|
#   puts "Saving #{agenda.name}"
#   agenda.save
# end

#parser starts

council_agendas.each do |agenda|
	sections 	= agenda.content.scrub.split("<br clear=\"all\">")
	items			= sections.map { |item| Nokogiri::HTML(item) }

	items.each do |item|
		item_number = item.xpath("#{SECTION_HEADER_TABLE}/font[@size='5']").text
		
		unless item_number.empty?
			File.open('dumping_to.txt', 'ab') do |f|
				raw_item = RawAgendaItem.parse(item_number, item)
				f.puts raw_item.to_s
			end
		end
	end
end

binding.pry
puts "" 

