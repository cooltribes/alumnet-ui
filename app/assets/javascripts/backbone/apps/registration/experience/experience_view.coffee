@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Experience.Form extends Marionette.ItemView
    template: 'registration/experience/templates/formAiesecExperience'
    className: 'row'

    initialize: ->
      ###Backbone.Validation.bind this,
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
      "change #group-avatar":"previewImage"###
    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = this.$('#group-avatar')
      formData.append('avatar', file[0].files[0])
      this.model.set(data)
      this.trigger("form:submit", this.model, formData)

    previewImage: (e)->
      input = @.$('#group-avatar')
      preview = @.$('#preview-avatar')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])
