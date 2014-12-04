@AlumNet.module 'RegistrationApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Profile.Form extends Marionette.ItemView
    template: 'registration/profile/templates/form'
    className: 'container-fluid'
    ui: 
     "birthCountry": "[name=birth_country]"   
     "resCountry": "[name=residence_country]"   
     "birthCity": "[name=birth_city]"   
     "resCity": "[name=residence_city]"   

    events:      
      "click button.js-submit":"submitClicked"
      "change #profile-avatar":"previewImage"
      "change @ui.birthCountry": "changeCity" 
      "change @ui.resCountry": "changeCity" 


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
      dropdowns = @ui.birthCountry.add(@ui.resCountry)  

      countries = new AlumNet.Entities.Countries
      
      countries.fetch 
        success: (collection, response, options)->
          fillCountries(collection, dropdowns)


    changeCity: (e) ->
      if $(e.target)[0] == @ui.birthCountry[0]
        countryId = @ui.birthCountry.val()         
        dropdown = @ui.birthCity
      else if $(e.target)[0] == @ui.resCountry[0]
        countryId = @ui.resCountry.val()         
        dropdown = @ui.resCity      
      
      cities = AlumNet.request("cities:get_cities", countryId)
      cities.fetch 
        success: (collection, response, options)->
          fillCities(collection, dropdown)

    
    fillCountries = (countries, dropdowns)->  
      content = AlumNet.request("countries:html", countries)
      dropdowns.html(content)


    fillCities = (cities, dropdown)->  
      content = AlumNet.request("cities:html", cities)
      dropdown.html(content)

      
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
