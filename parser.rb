require "nokogiri"
require	"awesome_print"
require "pry"

file = File.open("9688.html").read
items = file.scrub.split("<br clear=\"all\">")

preview = items.map do |item|
	"<div style='border: 1px solid red; margin-bottom: 50px'>#{item}</div>"
end.join

File.open("tester.html", 'w') {|f| f.write(preview) }


# doc = Nokogiri::HTML(File.open("9688.html"))
# doc.xpath("//table").css(".border")

# binding.pry

# print ""