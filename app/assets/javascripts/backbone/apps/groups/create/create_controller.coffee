@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    createGroup: ->
      group = AlumNet.request("group:new")
      createForm = new Create.GroupForm
        model: group
      AlumNet.mainRegion.show(createForm)

      createForm.on "form:submit", (view)->
        model = view.model
        formData = new FormData()
        data = Backbone.Syphon.serialize(view)
        _.forEach data, (value, key, list)->
          formData.append(key, value)
        file = view.$('#group-avatar')
        formData.append('avatar', file[0].files[0])
        model.set(data)
        if model.isValid(true)
          options_for_save =
            contentType: false
            processData: false
            data: formData
          group.save(data, options_for_save)