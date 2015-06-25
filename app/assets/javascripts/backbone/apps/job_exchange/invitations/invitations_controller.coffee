@AlumNet.module 'JobExchangeApp.Invitations', (Invitations, @AlumNet, Backbone, Marionette, $, _) ->
  class Invitations.Controller
    invitations: ->
      invitations = new AlumNet.Entities.TaskInvitationCollection
      invitations.fetch()
      invitationsView = new Invitations.TaskInvitations
        collection: invitations

      AlumNet.mainRegion.show(invitationsView)
      AlumNet.execute('render:job_exchange:submenu', undefined, 4)