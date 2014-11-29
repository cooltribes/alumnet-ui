@AlumNet.module 'GroupsApp.SubGroups', (SubGroups, @AlumNet, Backbone, Marionette, $, _) ->

  class SubGroups.GroupForm extends Marionette.ItemView
    template: 'groups/subgroups/templates/form'

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')
    events:
      "click button.js-submit":"submitClicked"
      "change #group-cover":"previewImage"
    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = this.$('#group-cover')
      formData.append('cover', file[0].files[0])
      this.model.set(data)
      this.trigger("form:submit", this.model, formData)

    previewImage: (e)->
      input = @.$('#group-cover')
      preview = @.$('#preview-cover')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])