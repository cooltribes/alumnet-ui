@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    createGroup: ->
      createForm = new Create.Group
      AlumNet.mainRegion.show(createForm)

      createForm.on "form:submit", (data, file)->
        group = AlumNet.request("group:new", {})
        formData = new FormData()
        $input = $('#group-avatar')
        _.forEach data, (value, key, list)->
          formData.append(key, value)

        formData.append('avatar', $input[0].files[0])
        group.save data,
          contentType: false
          processData: false
          data: formData
        AlumNet.trigger("groups:home", {})
