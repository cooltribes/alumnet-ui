@AlumNet.module 'MeetupExchangeApp', (MeetupExchangeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class MeetupExchangeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "meetup-exchange/discover": "discoverMeetupExchange"
      "meetup-exchange/your-tasks": "yourTasksMeetupExchange"
      "meetup-exchange/applied": "appliedMeetupExchange"
      "meetup-exchange/automatches": "automatchesMeetupExchange"
      "meetup-exchange/invitations": "invitationsMeetupExchange"
      "meetup-exchange/new": "createMeetupExchange"
      "meetup-exchange/:id/edit": "updateMeetupExchange"
      "meetup-exchange/:id": "showMeetupExchange"

  API =
    discoverMeetupExchange: ->
      AlumNet.setTitle('Discover Meetups')
      controller = new MeetupExchangeApp.Main.Controller
      controller.showMainLayout("discoverMeetups")
    yourTasksMeetupExchange: ->
      AlumNet.setTitle('My Meetups')
      controller = new MeetupExchangeApp.Main.Controller
      controller.showMainLayout("manageMeetups")
    appliedMeetupExchange: ->
      AlumNet.setTitle('Applied Meetups')
      controller = new MeetupExchangeApp.Main.Controller
      controller.showMainLayout("myApplications")
    automatchesMeetupExchange: ->
      AlumNet.setTitle('Meetups Sugestions')
      controller = new MeetupExchangeApp.Main.Controller
      controller.showMainLayout("automatches")
    invitationsMeetupExchange: ->
      AlumNet.setTitle('Meetups Invitations')
      controller = new MeetupExchangeApp.Invitations.Controller
      controller.invitations()
    createMeetupExchange: ->
      AlumNet.setTitle('Create New Meetup')
      if AlumNet.current_user.get("profinda_api_token")
        controller = new MeetupExchangeApp.Create.Controller
        controller.create()
      else
        AlumNet.getProfindaApiToken()
    updateMeetupExchange: (id)->
      controller = new MeetupExchangeApp.Create.Controller
      controller.update(id)
    showMeetupExchange: (id)->
      controller = new MeetupExchangeApp.Show.Controller
      controller.show(id)

  AlumNet.on "program:meetup:my", ->
    AlumNet.navigate("meetup-exchange/your-tasks")
    API.yourTasksMeetupExchange()

  AlumNet.on "program:meetup:discover", ->
    AlumNet.navigate("meetup-exchange")
    API.discoverMeetupExchange()

  AlumNet.addInitializer ->
    new MeetupExchangeApp.Router
      controller: API