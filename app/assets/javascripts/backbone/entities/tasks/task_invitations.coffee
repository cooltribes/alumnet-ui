@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.TaskInvitation extends  Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/task_invitations'

  class Entities.TaskInvitationCollection extends Backbone.Collection
    model:
      Entities.TaskInvitation
    url: ->
      AlumNet.api_endpoint + '/task_invitations'
