@AlumNet.module 'GroupsApp.Members', (Members, @AlumNet, Backbone, Marionette, $, _) ->
  class Members.Controller
    listMembers: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        if group.isClose() && not group.userIsMember()
          $.growl.error({ message: "You cannot see information on this Group. This is a Closed Group" })
        else if group.isSecret() && not group.userIsMember()
          AlumNet.trigger('show:error', 404)
        else
          layout = AlumNet.request("group:layout", group)
          header = AlumNet.request("group:header", group)
          membersLayout = new Members.MembersLayout
          AlumNet.execute('render:groups:submenu')

          # render the layouts firsts
          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(membersLayout)

          # Alumni View
          members = AlumNet.request("membership:members", group.id, {})
          membersView = new Members.MembersView
            model: group
            collection: members
          membersLayout.alumni.show(membersView)
          membersView.on 'members:search', (querySeach)->
            members.fetch
              data: querySeach

          # Requests View -- Only for admins
          if group.userIsAdmin()
            requests = AlumNet.request("membership:requests", group.id)
            requestsView = new Members.RequestsView
              model: group
              collection: requests
            membersLayout.requests.show(requestsView)

            requestsView.on 'childview:membership:accepted', (childView)->
              model = childView.model
              requestsCollection = model.collection
              membersCollecttion = members #line 17
              model.save { approved: true},
                success: (model)->
                  requestsCollection.remove(model)
                  membersCollecttion.add(model)

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)



