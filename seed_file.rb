require "net/http"
require "nokogiri"
require "open-uri"
require "pry"
require "awesome_print"
require_relative "raw_agenda"
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

base_uri     = "http://app.toronto.ca/tmmis/"
calendar_uri = URI("#{base_uri}meetingCalendarView.do")
report_uri   = URI("#{base_uri}viewPublishedReport.do?")
meeting_ids  = []

12.times do |i|
  calendar_page = Net::HTTP.post_form(calendar_uri, calendar_params(i, 2015)).body
  page          = Nokogiri::HTML(calendar_page)
  anchors       = page.css("#calendarList .list-item a")
  anchors       = anchors.to_ary
  
  meeting_ids << anchors.map do |a|
    a.attr("href").split("=").last if a.text.include? "City Council"
  end.reject(&:nil?).uniq
end

meeting_ids.flatten!

meeting_ids.map do |id|
  puts "Checking #{id}"
	RawAgenda.new(id).save
end

#parser starts
meeting_ids.each do |id|
  puts "Parsing #{id}"

  content  = open("agendas/#{id}.html")
	sections = content.scrub.split("<br clear=\"all\">")
	items    = sections.map { |item| Nokogiri::HTML(item) }

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

