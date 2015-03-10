require "nokogiri"
require	"awesome_print"
require "pry"

file = File.open("agendas/9688.html").read
sections = file.scrub.split("<br clear=\"all\">     <table class=\"border\`"")

preview = sections.map do |section|
	"<div style='border: 2px solid red; margin-bottom: 50px'> <table class=\"border\"#{section}</div>"
end.join

File.open("tester.html", 'w') {|f| f.write(preview) }

items = sections.map { |section| Nokogiri::HTML(section) }

binding.pry

print ""