@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    createGroup: ->
      group = AlumNet.request("group:new")
      createForm = new Create.GroupForm
        model: group
      AlumNet.mainRegion.show(createForm)
      AlumNet.execute('render:groups:submenu')

      createForm.on "form:submit", (model, data)->
        if model.isValid(true)
          options_for_save =
            wait: true
            contentType: false
            processData: false
            data: data
            #model return id == undefined, this is a temporally solution.
            success: (model, response, options)->
              AlumNet.trigger "groups:invite", model.id
          model.save(data, options_for_save)
          #here model.id is undefined
          # AlumNet.trigger("groups:invite", group.get('id')
