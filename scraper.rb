
#viewPublishedReport.do? getCouncilMinutesReport
                        #getMemberVoteReport
#viewPublishedReport.do? getAgendaReport

require "net/http"
require "nokogiri"
require "open-uri"
require "pry"
require "awesome_print"

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
  File.open(file_name, 'w') {|f| f.write(input) }
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

binding.pry

puts ""
