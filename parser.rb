require "nokogiri"
# require	"awesome_print"
require "pry"

file = File.open("9688.html").read
items = file.scrub.split("<br clear=\"all\">")

doc = Nokogiri::HTML(File.open("9688.html"))
doc.xpath("//table").css(".border")


#getting number of brs with attr clear=all 
doc.css("#ss_councilAgendaReport").xpath('//*[@clear="all"]') 

binding.pry

print ""