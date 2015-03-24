@AlumNet.module 'EventsApp.Attendances', (Attendances, @AlumNet, Backbone, Marionette, $, _) ->
  class Attendances.Controller
    showAttendances: (event_id)->
      event = AlumNet.request("event:find", event_id)
      current_user = AlumNet.current_user
      event.on 'find:success', (response, options)->
        if event.isClose() && not event.userIsInvited()
          $.growl.error({ message: "You cannot see information on this Event. This is a Closed Event" })
        else if event.isSecret() && not event.userIsInvited()
          AlumNet.trigger('show:error', 404)
        else
          attendances = AlumNet.request('attendance:entities', event_id)
          attendancesView = new Attendances.AttendancesView
            collection: attendances
            model: event

          AlumNet.mainRegion.show(attendancesView)
          AlumNet.execute('render:events:submenu')

      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)
