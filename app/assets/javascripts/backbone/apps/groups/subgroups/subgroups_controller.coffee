@AlumNet.module 'GroupsApp.SubGroups', (SubGroups, @AlumNet, Backbone, Marionette, $, _) ->
  class SubGroups.Controller
    createSubGroup: (group_id)->
      group = AlumNet.request('group:find', group_id)
      # group.on 'find:success', (response, options)->
      subgroup = AlumNet.request('subgroup:new', group.id)
      createForm = new SubGroups.GroupForm
        group: group
        model: subgroup
      AlumNet.mainRegion.show(createForm)
      AlumNet.execute('render:groups:submenu')

      createForm.on 'form:submit', (model, data)->
        if model.isValid(true)
          options_for_save =
            wait: true
            contentType: false
            processData: false
            data: data
            success: (model, response, options)->
              AlumNet.trigger 'groups:invite', model.id
          model.save(data, options_for_save)

    listSubGroups: (group_id)->
      group = AlumNet.request("group:find", group_id)
      # group.on 'find:success', (response, options)->
      layout = AlumNet.request("group:layout", group)
      header = AlumNet.request("group:header", group)
      subgroups = group.subgroups
      subgroups.fetch()
      subgroupsView = new SubGroups.GroupsView
        model: group
        collection: subgroups
      AlumNet.mainRegion.show(layout)
      layout.header.show(header)
      layout.body.show(subgroupsView)
      AlumNet.execute('render:groups:submenu')

      #When join link is clicked
      subgroupsView.on 'childview:join', (childView) ->
        group_id = { group_id: childView.model.get('id') }
        join = AlumNet.request('membership:request', group_id)
        join.on 'save:success', (response, options)->
          console.log response.responseJSON

        join.on 'save:error', (response, options)->
          console.log response.responseJSON