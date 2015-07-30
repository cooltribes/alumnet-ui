@AlumNet.module 'BusinessExchangeApp.Invitations', (Invitations, @AlumNet, Backbone, Marionette, $, _) ->
  class Invitations.Controller
    invitations: ->
      invitations = new AlumNet.Entities.TaskInvitationCollection
      invitations.fetch()
      invitationsView = new Invitations.TaskInvitations
        collection: invitations
      console.log invitations

      AlumNet.mainRegion.show(invitationsView)
      AlumNet.execute('render:business_exchange:submenu', undefined, 2)