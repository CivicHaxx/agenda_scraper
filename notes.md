notes.md

base_uri: http://app.toronto.ca/tmmis/

POST
routes:  
  meetingCalendarView.do? 
    params: 
      isToday:       "false",
      expand:        "N",
      view:          "List",
      selectedMonth: month,
      selectedYear:  year,
      includeAll:    "on"
  viewPublishedReport.do?
    params:
    function:  "getCouncilAgendaReport",
    meetingId: meeting_id
      
GET
routes:
  get a list of agenda items. urls here lead to a page that load js :(
  "http://app.toronto.ca/tmmis/viewAgendaItemList.do?function=getAgendaItems&meetingId=9992&d=1426179933487"
  viewAgendaItemList.do?
    function=
      getAgendaItems
      meetingId =
        number
      d = 
        unix time?
        
  gets an individual agenda item
  "http://app.toronto.ca/tmmis/viewAgendaItemDetails.do?function=getCouncilMinutesItemPreview&agendaItemId=43317"
  viewAgendaItemDetails.do?
    function=
      getCouncilMinutesItemPreview
    agendaItemId=
      number

functions: 
  getAgendaItems
    meetingID
  getMinutesItemPreview
    agendaItemId 
