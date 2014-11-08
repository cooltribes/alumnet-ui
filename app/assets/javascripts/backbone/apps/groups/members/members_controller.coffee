@AlumNet.module 'GroupsApp.Members', (Members, @AlumNet, Backbone, Marionette, $, _) ->
  class Members.Controller
    listMembers: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        members = AlumNet.request("members:entities", group.id, {})
        console.log members
        membersView = new Members.MembersView
          model: group
          collection: members
        AlumNet.mainRegion.show(membersView)

        membersView.on 'members:search', (querySeach)->
          console.log querySeach,group
          members.fetch
            data: querySeach
          # search = AlumNet.request("members:entities", group.id, querySearch)

      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")



