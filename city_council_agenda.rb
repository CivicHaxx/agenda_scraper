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