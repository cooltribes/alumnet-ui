@AlumNet.module 'GroupsApp.Invite', (Invite, @AlumNet, Backbone, Marionette, $, _) ->
  class Invite.Controller
    listUsers: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'fetch:success', (response, options)->
        users = AlumNet.request("user:entities", {})
        usersView = new Invite.Users
          model: group
          collection: users
        AlumNet.mainRegion.show(usersView)

        usersView.on 'childview:invite', (childView) ->
          attrs = { user_id: childView.model.get('id'), group_id: group.get('id')}
          invitation = AlumNet.request("user:invitation:send", attrs)

          invitation.on 'save:error', (response, options)->
            childView.removeLink()


      group.on 'fetch:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")