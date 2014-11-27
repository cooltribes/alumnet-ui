@AlumNet.module 'RegistrationApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Profile.Form extends Marionette.ItemView
    template: 'registration/profile/templates/form'
    className: 'container-fluid'

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

    onShow: ->
      dropdowns = $("[name=birth_country], [name=residence_country]", $(@el))  
      
      countries = new AlumNet.Entities.Countries
      
      countries.fetch 
        success: (collection, response, options)->
          fillCountries(collection, dropdowns)

      # content = AlumNet.request("countries:html", countries)     
      # console.log content
      # dropdowns.html(content)

    
    fillCountries = (countries, dropdowns)->  
      # console.log dropdowns    
      # console.log countries    
      content = AlumNet.request("countries:html", countries)
      dropdowns.html(content)



    events:
      "click button.js-submit":"submitClicked"
      "change #profile-avatar":"previewImage"

      
    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)      
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#profile-avatar')
      formData.append('avatar', file[0].files[0])
      this.model.set(data)
      @trigger("form:submit", this.model, formData)


    previewImage: (e)->
      input = @.$('#profile-avatar')
      preview = @.$('#preview-avatar')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])
