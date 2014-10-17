@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    createGroup: ->
      group = AlumNet.request("group:new")
      createForm = new Create.GroupForm
        model: group
      AlumNet.mainRegion.show(createForm)

      createForm.on "form:submit", (model, data)->
        if model.isValid(true)
          options_for_save =
            contentType: false
            processData: false
            data: data
          group.save(data, options_for_save)
          AlumNet.trigger("groups:home")
