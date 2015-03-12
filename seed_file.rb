require "net/http"
require "nokogiri"
require "open-uri"
require "pry"
require "awesome_print"
require_relative "city_council_agenda"
require_relative "raw_agenda_item"

SECTION_HEADER_TABLE = "//table[@class='border']/tr/td"

def calendar_params(month, year)
  {
    function:      "meetingCalendarView",
    isToday:       "false",
    expand:        "N",
    view:          "List",
    selectedMonth: month,
    selectedYear:  year,
    includeAll:    "on"
  }
end

base_uri        = "http://app.toronto.ca/tmmis/"
calendar_uri    = URI("#{base_uri}meetingCalendarView.do")
report_uri      = URI("#{base_uri}viewPublishedReport.do?")
meeting_ids   = []

12.times do |i|
  calendar_page = Net::HTTP.post_form(calendar_uri, calendar_params(i, 2015)).body
  page          = Nokogiri::HTML(calendar_page)
  anchor        = page.css("#calendarList .list-item a")
  meeting_ids << anchor.attr('href').text.split("=").last if anchor.text.include? "City Council"
end

council_agendas = meeting_ids.map do |meeting_id|
  puts "Checking #{meeting_id}"
	CityCouncilAgenda.new(meeting_id).save
end

# council_agendas.each do |agenda|
#   puts "Saving #{agenda.name}"
#   agenda.save
# end

#parser starts

council_agendas.each do |agenda|
  print "]"
  binding.pry
	sections 	= agenda.content.scrub.split("<br clear=\"all\">")
	items			= sections.map { |item| Nokogiri::HTML(item) }

	items.each do |item|
		item_number = item.xpath("#{SECTION_HEADER_TABLE}/font[@size='5']").text
		
		unless item_number.empty?
			File.open('dumping_to.txt', 'ab') do |f|
				raw_item = RawAgendaItem.parse(item_number, item)
				#f.puts raw_item.to_s
			end
		end
	end
end

puts "" 

