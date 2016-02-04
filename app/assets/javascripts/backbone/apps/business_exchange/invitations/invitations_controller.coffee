@AlumNet.module 'BusinessExchangeApp.Invitations', (Invitations, @AlumNet, Backbone, Marionette, $, _) ->
  class Invitations.Controller
    invitations: ->
      invitations = new AlumNet.Entities.TaskInvitationCollection
      invitations.fetch
        data: { q: { task_help_type_eq: "task_business_exchange" } }
      invitationsView = new Invitations.TaskInvitations
        collection: invitations
      AlumNet.mainRegion.show(invitationsView)
      #AlumNet.execute('render:business_exchange:submenu', undefined, 2)