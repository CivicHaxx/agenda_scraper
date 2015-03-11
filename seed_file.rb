require "net/http"
require "nokogiri"
require "open-uri"
require "pry"
require "awesome_print"

require_relative "city_council_agenda"
require_relative "raw_agenda_item"

SECTION_HEADER_TABLE = "//table[@class='border']/tr/td"

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

base 					= URI("http://app.toronto.ca/tmmis/meetingCalendarView.do")
calendar_page = Net::HTTP.post_form(base, report_params(1, 2015)).body
page 					= Nokogiri::HTML(calendar_page)

meeting_links = page.css("#calendarList .list-item a").map do |anchor| 
  anchor.attr('href') if anchor.text.include? "City Council"
end.reject(&:nil?).uniq

council_agendas = meeting_links.map do |meeting_link|
	puts "Checking #{meeting_link}"

  site 				= "http://app.toronto.ca" + meeting_link
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

puts "" 

