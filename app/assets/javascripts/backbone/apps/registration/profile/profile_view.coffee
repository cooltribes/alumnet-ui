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

    ui:
      'selectBirthCountries': '#js-birth-countries'
      'selectBirthCities': '#js-birth-cities'
      'selectResidenceCountries': '#js-residence-countries'
      'selectResidenceCities': '#js-residence-cities'
      'datePickerBorn': '.js-date-born'

    events:
      'click button.js-submit': 'submitClicked'
      'change #profile-avatar': 'previewImage'
      'change #js-birth-countries': 'setBirthCities'
      'change #js-residence-countries': 'setResidenceCities'


    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#profile-avatar')
      formData.append('avatar', file[0].files[0])
      @model.set(data)
      @trigger 'form:submit', @model, formData

    previewImage: (e)->
      input = @.$('#profile-avatar')
      preview = @.$('#preview-avatar')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    setBirthCities: (e)->
      url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
      @ui.selectBirthCities.select2(@optionsForSelectCities(url))

    setResidenceCities: (e)->
      url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
      @ui.selectResidenceCities.select2(@optionsForSelectCities(url))


    optionsForSelectCities: (url)->
      placeholder: "Select a City"
      minimumInputLength: 2
      ajax:
        url: url
        dataType: 'json'
        data: (term)->
          q:
            name_cont: term
        results: (data, page) ->
          results:
            data
      formatResult: (data)->
        data.name
      formatSelection: (data)->
        data.name

    onRender: ->
      @ui.datePickerBorn.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'

      @ui.selectBirthCities.select2
        placeholder: "Select a City"
        data: []

      @ui.selectResidenceCities.select2
        placeholder: "Select a City"
        data: []

      data = CountryList.toSelect2()

      @ui.selectBirthCountries.select2
        placeholder: "Select a Country"
        data: data

      @ui.selectResidenceCountries.select2
        placeholder: "Select a Country"
        data: data

      @ui.selectBirthCountries.select2('val', @model.get('birth_country'))
      @ui.selectResidenceCountries.select2('val', @model.get('residence_country'))

