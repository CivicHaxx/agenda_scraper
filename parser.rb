require "net/http"
require "nokogiri"
require "open-uri"
require "pry"
require "awesome_print"
require 'epitools/core_ext/enumerable'

# gem 'epitools', require: 'epitools/core_ext/enumerable'

base = URI("http://app.toronto.ca/tmmis/meetingCalendarView.do")

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

def council_agenda_url(id)
  "http://app.toronto.ca/tmmis/viewPublishedReport.do?function=getCouncilAgendaReport&meetingId=#{id}"
end

def agenda_url(id)
  "http://app.toronto.ca/tmmis/viewPublishedReport.do?function=getAgendaReport&meetingId=#{id}"
end

def save(file_name, input)
  File.open("agendas/#{file_name}", 'w') {|f| f.write(input) }
end

calendar_page = Net::HTTP.post_form(base, report_params(1, 2015)).body

page = Nokogiri::HTML(calendar_page)

meeting_links = page.css("#calendarList .list-item a").map do |anchor| 
  anchor.attr('href') if anchor.text.include? "City Council"
end.reject(&:nil?)

agenda_urls = meeting_links.map do |meeting_link|
  puts "Checking #{meeting_link}"
  site = "http://app.toronto.ca" + meeting_link
  agenda_list = Nokogiri::HTML(open(site))

  agenda_list.css("#accordion h3").map do |x| 
      x.attr('id').gsub("header", "")
  end.map{|id| council_agenda_url(id) }
end.flatten.uniq.sort

agenda_urls.each do |url|
  file_name = url.split("=").last + ".html"
  puts "Saving #{file_name}"
  html = open(url).read
  save(file_name, html)
end

#parser starts

file = File.open("agendas/9688.html").read
sections = file.scrub.split("<br clear=\"all\">")

preview = sections.map do |section|
	"<div style=\"border: 2px solid red; margin-bottom: 50px\">#{section}</div>"
end.join

File.open("preview.html", 'w') {|f| f.write(preview) }

items = sections.map { |item| Nokogiri::HTML(item) }

items.each do |item|

	section_header_table = "//table[@class='border']/tr/td"

	item_number = item.xpath("#{section_header_table}/font[@size='5']").text
	unless item_number.empty?
		item_type = item.xpath("#{section_header_table}/p/font").first.text.capitalize.chop
		ward = item.xpath("#{section_header_table}/p/font").last.text.chop
		item_title = item.xpath('//table/tr/td/font/b').first.text
		item_tables = item.xpath('//table')
		raw_html = item.xpath('//table')[2..item_tables.length]
		

		# if item_number.start_with? "MM"
		# 	member_motion = item.xpath('//table/tr/td/font/b').first.text
		# 	member_motion = item.xpath('//table/tr/td/font/b')[1].text if member_motion.start_with? "Member Motions"
		# 	by = member_motion.split(" - by ")
		# 	councillor = by[1].split(", seconded by ")
		# 	# binding.pry if item_number == "MM3.1"
		# 	# binding.pry if item_number == "MM3.35"
		# end
	end

end

binding.pry
puts "" 