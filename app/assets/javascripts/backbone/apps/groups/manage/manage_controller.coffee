@AlumNet.module 'GroupsApp.Manage', (Manage, @AlumNet, Backbone, Marionette, $, _) ->
  class Manage.Controller
    manageGroups: ->
      current_user = AlumNet.current_user
      groups = AlumNet.request("membership:groups", current_user.id, {})
      console.log groups



