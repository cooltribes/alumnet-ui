@AlumNet.module 'GroupsApp.Members', (Members, @AlumNet, Backbone, Marionette, $, _) ->
  class Members.Controller
    listMembers: (id)->
      group = AlumNet.request("group:find", id)
      # group.on 'find:success', (response, options)->
      layout = AlumNet.request("group:layout", group)
      header = AlumNet.request("group:header", group)
      members = AlumNet.request("membership:members", group.id, {})
      membersView = new Members.MembersView
        model: group
        collection: members
      AlumNet.mainRegion.show(layout)
      layout.header.show(header)
      layout.body.show(membersView)
      AlumNet.execute('render:groups:submenu')

      membersView.on 'members:search', (querySeach)->
        members.fetch
          data: querySeach

      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")



