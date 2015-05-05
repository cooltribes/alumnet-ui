@AlumNet.module 'GroupsApp.BanerList', (BanerList, @AlumNet, Backbone, Marionette, $, _) ->
  
  class BanerList.Controller
    banerList: (group_id)->
      group = AlumNet.request('group:find', group_id)
      current_user = AlumNet.current_user
      group.on 'find:success', (response, options)->
        if group.isClose() && not group.userIsMember()
          $.growl.error({ message: "You cannot see information on this Group. This is a Closed Group" })
        else if group.isSecret() && not group.userIsMember()
          AlumNet.trigger('show:error', 404)
        else
          layout = AlumNet.request("group:layout", group,6)
          header = AlumNet.request("group:header", group)

          banerTable = new BanerList.BanerTable
          createBaner = new BanerList.CreateView
          body = new BanerList.Layout
            model: group
            current_user: current_user
          

          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(body)
          body.table.show(banerTable)
          body.create.show(createBaner)
          AlumNet.execute('render:groups:submenu')
           