require          "net/http"
require          "nokogiri"
require          "open-uri"
require          "pry"
require          "awesome_print"
require_relative "raw_agenda"
require_relative "raw_agenda_item"

BASE_URI             = "http://app.toronto.ca/tmmis/"

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
# TO DO: Make meetingId class that takes params like year, committee name etc.
#        and generates a list of meeting ids to be passed into RawAgenda
calendar_uri  = URI("#{BASE_URI}meetingCalendarView.do")
calendar_page = Net::HTTP.post_form(calendar_uri, calendar_params(12, 2014)).body
page          = Nokogiri::HTML(calendar_page)
anchors       = page.css("#calendarList .list-item a")
anchors       = anchors.to_ary

meeting_ids = anchors.map do |a|
  a.attr("href").split("=").last if a.text.include? "City Council"
end.reject(&:nil?).uniq.flatten

puts "I found #{meeting_ids.length} meeting IDs."

meeting_ids.map do |id|
  puts "Saving #{id} ✔ "
	RawAgenda.new(id).save
end

#parser starts
meeting_ids.each do |id|
  puts "Parsing #{id} ⚡  "
  content  = open("agendas/#{id}.html").read
	sections = content.scrub.split("<br clear=\"all\">")
	items    = sections.map { |item| Nokogiri::HTML(item) }
	items.each do |item|
		item_number = item.xpath("//table[@class='border']/tr/td/font[@size='5']").text
		
		unless item_number.empty?
			File.open('dumping_#{id}_to.txt', 'ab') do |f|
				raw_item = RawAgendaItem.parse(item_number, item)
				#f.puts raw_item.to_s
			end
		end
	end
end

puts "★ ★ ★ ★ ★ ★ ★ ★ ★ ★ " 

