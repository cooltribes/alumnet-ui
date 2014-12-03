@AlumNet.module 'GroupsApp.SubGroups', (SubGroups, @AlumNet, Backbone, Marionette, $, _) ->
  class SubGroups.Controller
    createSubGroup: (group_id)->
      group = AlumNet.request('group:find', group_id)
      # group.on 'find:success', (response, options)->
      subgroup = AlumNet.request('subgroup:new', group.id)
      createForm = new SubGroups.GroupForm
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
