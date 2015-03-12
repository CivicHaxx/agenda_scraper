class RawAgenda
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
		URI "http://app.toronto.ca/tmmis/viewPublishedReport.do?"
	end

	def agenda_params(meeting_id)
	  {
	    function:  "getCouncilAgendaReport",
	    meetingId: meeting_id
	  }
	end

	def content
		@content = Net::HTTP.post_form(url, agenda_params(id)).body
		# @content ||= begin
		# 	if File.exist?(filename)
		# 		open(filename).read
		# 	else
		# 		Net::HTTP.post_form(url, agenda_params(id)).body
		# 	end
		# end
	end

	def save
	  File.open(filename, 'w') {|f| f.write(content) }
	end
end