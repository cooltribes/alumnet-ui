@AlumNet.module 'RegistrationApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Contact.Form extends Marionette.ItemView
    template: 'registration/contact/templates/form'
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
      "change #group-avatar":"previewImage"###

    events:
      "click button.js-submit":"submitClicked"

    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      numberObj = {
        "contact_type": 1,
        "info": "",
        "privacy": 1,

      }

      contactAttrs = new Array()
      _.forEach data, (value, key, list)->
        
        if (key == "code" or key == "number")
          numberObj.info += value
        else if (key == "numberPrivacy" or key == "number")
          numberObj.privacy = value          
        else  

          _.forEach value.contact_type, (value, key, list)->
            if value != ""
              contactAttrs[key] = {
                "contact_type": value,
                "info": "",
                "privacy": 0,
              }

            console.log key 

          console.log contactAttrs 
          # formData.append(key, value)



      console.log numberObj
      console.log data       
      
      
      # this.model.set(data)
      # this.trigger("form:submit", this.model, formData)

    previewImage: (e)->
      input = @.$('#group-avatar')
      preview = @.$('#preview-avatar')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])
