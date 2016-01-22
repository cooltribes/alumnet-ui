@AlumNet.module 'RegistrationApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->

  class Main.BasicInformation extends Marionette.ItemView
    template: 'registration/basic_information/templates/form'
    className: 'container-fluid'

    initialize: (options)->
      @step = options.step
      @layout = options.layout
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

    templateHelpers: ->
      model = @model
      birth_city_helper: @model.get('birth_city').id
      residence_city_helper: @model.get('residence_city').id
      date_born: @model.getDateBorn()
      avatar_picture: ->
        if model.get('avatar_url')
          model.get('avatar_url')
        else if model.get('avatar').extralarge
          model.get('avatar').extralarge
        else
          null
      select_gender: (value)->
        if value == model.get('gender') then 'selected' else ''

      isVisible: !AlumNet.current_user.isExternal()

    ui:
      'selectBirthCountries': '#js-birth-countries'
      'selectBirthCities': '#js-birth-cities'
      'selectResidenceCountries': '#js-residence-countries'
      'selectResidenceCities': '#js-residence-cities'
      'datePickerBorn': '.js-date-born'
      'linkLinkedin': '.js-linkedin-import'
      'changeImageProfile' : '#js-changePicture'

    events:
      'click button.js-submit': 'submitClicked'
      'change #profile-avatar': 'previewImage'
      'change #js-birth-countries': 'setBirthCities'
      'change #js-residence-countries': 'setResidenceCities'
      'click @ui.linkLinkedin': 'linkedinClicked'
      'click @ui.changeImageProfile' : 'changePictureProfile'


    changePictureProfile: (e)->
      e.preventDefault()
      $('#profile-avatar').click()


    linkedinClicked: (e)->
      if gon.linkedin_profile && gon.linkedin_profile.profile
        e.preventDefault()
        @model.set(gon.linkedin_profile.profile)
        ## find and set residence city by iso_code
        country_code = gon.linkedin_profile.profile.country_code
        country = AlumNet.request 'find:country:iso', country_code
        if country
          @model.set('residence_country', { id: country.id, name: country.get('name') })
        @render()

    saveData: ()->
      layout = @layout
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#profile-avatar')
      formData.append('avatar', file[0].files[0])
      @model.set(data)
      if @model.isValid(true)
        @model.save data,
          wait: true
          contentType: false
          processData: false
          data: formData
          success: ->
            layout.goToNext()

    saveStepData: (step, indexStep)->
      layout = @layout
      view = @
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#profile-avatar')
      formData.append('avatar', file[0].files[0])
      @model.set(data)
      if @model.isValid(true)

        @model.save data,
          wait: true
          contentType: false
          processData: false
          data: formData
          success: ->
            profile = AlumNet.current_user.profile
            stepActual = profile.get("register_step")
            
            if stepActual == "basic_information"
              Backbone.ajax
                url: AlumNet.api_endpoint + "/me/registration"
                method: "put"
                async: false
                success: (data)->
                  stepActual = data.current_step
                error: (data)->
                  $.growl.error { message: data.status }
              profile.set("register_step", stepActual)

            layout.navigateStep(step, indexStep)

    previewImage: (e)->
      input = @.$('#profile-avatar')
      preview = @.$('#preview-avatar')
      if input[0] && input[0].files[0]
        @.$('#avatar-url').val('')
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    setBirthCities: (e)->
      url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
      @ui.selectBirthCities.select2(@optionsForSelectCities(url, false))

    setResidenceCities: (e)->
      url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
      @ui.selectResidenceCities.select2(@optionsForSelectCities(url, false))


    optionsForSelectCities: (url, initialValue)->
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
      initSelection: (element, callback)->
        callback(initialValue) if initialValue

    onRender: ->
      limit_date = moment().subtract(20, 'years').format("YYYY-MM-DD")
      @ui.datePickerBorn.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: ['1910-01-01', limit_date]

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

      birthCountry = @model.get('birth_country')
      birthCity = @model.get('birth_city')
      residenceCountry = @model.get('residence_country')
      residenceCity = @model.get('residence_city')

      ##Initial values for Countries
      @ui.selectBirthCountries.select2('val', birthCountry.id)
      @ui.selectResidenceCountries.select2('val', residenceCountry.id)

      ##Initial values for Birth City
      url_birth_city = AlumNet.api_endpoint + '/countries/' + birthCountry.id + '/cities'
      initial_birth_city = { id: birthCity.id, name: birthCity.text }
      @ui.selectBirthCities.select2(@optionsForSelectCities(url_birth_city, initial_birth_city))

      ##Initial values for Residence City
      url_residence_city = AlumNet.api_endpoint + '/countries/' + residenceCountry.id + '/cities'
      initial_residence_city = { id: residenceCity.id, name: residenceCity.text }
      @ui.selectResidenceCities.select2(@optionsForSelectCities(url_residence_city, initial_residence_city))
