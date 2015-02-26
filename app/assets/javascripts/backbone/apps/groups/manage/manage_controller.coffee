@AlumNet.module 'GroupsApp.Manage', (Manage, @AlumNet, Backbone, Marionette, $, _) ->
  class Manage.Controller
    manageGroups: ->
      current_user = AlumNet.current_user
      groups = AlumNet.request("membership:groups", current_user.id, {})
      groupsView = new Manage.GroupsView
        collection: groups
      AlumNet.mainRegion.show(groupsView)


      groupsView.on 'childview:click:leave', (childView)->
        membership = AlumNet.request("membership:destroy", childView.model)
        membership.on 'destroy:success', ->
          console.log "Destroy Ok"