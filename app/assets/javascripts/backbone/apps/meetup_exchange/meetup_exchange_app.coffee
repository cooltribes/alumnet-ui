@AlumNet.module 'MeetupExchangeApp', (MeetupExchangeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class MeetupExchangeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "meetup-exchange": "discoverMeetupExchange"
      "meetup-exchange/your-tasks": "yourTasksMeetupExchange"
      "meetup-exchange/applied": "appliedMeetupExchange"
      "meetup-exchange/automatches": "automatchesMeetupExchange"
      "meetup-exchange/invitations": "invitationsMeetupExchange"
      "meetup-exchange/new": "createMeetupExchange"
      "meetup-exchange/:id/edit": "updateMeetupExchange"
      "meetup-exchange/:id": "showMeetupExchange"

  API =
    discoverMeetupExchange: ->
      document.title = 'AlumNet - Discover Meetups'
      controller = new MeetupExchangeApp.Discover.Controller
      controller.discover()
    yourTasksMeetupExchange: ->
      document.title = 'AlumNet - My Meetups'
      controller = new MeetupExchangeApp.YourTasks.Controller
      controller.your_tasks()
    appliedMeetupExchange: ->
      document.title = 'AlumNet - Applied Meetups'
      controller = new MeetupExchangeApp.Applied.Controller
      controller.applied()
    automatchesMeetupExchange: ->
      document.title = 'AlumNet - Meetups Sugestions'
      controller = new MeetupExchangeApp.AutoMatches.Controller
      controller.automatches()
    invitationsMeetupExchange: ->
      document.title = 'AlumNet - Meetups Invitations'
      controller = new MeetupExchangeApp.Invitations.Controller
      controller.invitations()
    createMeetupExchange: ->
      document.title = 'AlumNet - Create New Meetup'
      controller = new MeetupExchangeApp.Create.Controller
      controller.create()
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