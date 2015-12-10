@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    createGroup: ->
      current_user = AlumNet.current_user
      group = AlumNet.request("group:new")
      createForm = new Create.GroupForm
        model: group
        user: current_user

      AlumNet.mainRegion.show(createForm)
      #AlumNet.execute('render:groups:submenu')

      createForm.on "form:submit", (model, data)->
        if model.isValid(true)
          options_for_save =
            wait: true
            contentType: false
            processData: false
            data: data
            success: (model, response, options)->
              AlumNet.trigger "groups:invite", model.id
            error: (model, response, options)->
              $.growl.error({ message: response.responseJSON.message })
          model.save(data, options_for_save)