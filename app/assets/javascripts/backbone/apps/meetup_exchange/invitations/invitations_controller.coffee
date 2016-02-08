@AlumNet.module 'MeetupExchangeApp.Invitations', (Invitations, @AlumNet, Backbone, Marionette, $, _) ->
  class Invitations.Controller
    invitations: ->
      invitations = new AlumNet.Entities.TaskInvitationCollection
      invitations.fetch
        data: { q: { task_help_type_eq: "task_meetup_exchange" } }
      invitationsView = new Invitations.TaskInvitations
        collection: invitations

      AlumNet.mainRegion.show(invitationsView)
      #AlumNet.execute('render:meetup_exchange:submenu', undefined, 2)