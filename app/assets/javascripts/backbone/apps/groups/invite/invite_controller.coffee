@AlumNet.module 'GroupsApp.Invite', (Invite, @AlumNet, Backbone, Marionette, $, _) ->
  class Invite.Controller
    listUsers: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        users = AlumNet.request("user:entities", {})
        usersView = new Invite.Users
          model: group
          collection: users
        AlumNet.mainRegion.show(usersView)

        #When invite link is clicked
        usersView.on 'childview:invite', (childView) ->
          attrs = { user_id: childView.model.get('id'), group_id: group.get('id')}
          invitation = AlumNet.request("user:invitation:send", attrs)
          invitation.on 'save:success', (response, options)->
            childView.removeLink()
          invitation.on 'save:error', (response, options)->
            console.log response.responseJSON

        #When search button is clicked
        usersView.on 'users:search', (querySearch)->
          console.log querySearch
          searchedGroups = AlumNet.request("user:entities", querySearch)

      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")



