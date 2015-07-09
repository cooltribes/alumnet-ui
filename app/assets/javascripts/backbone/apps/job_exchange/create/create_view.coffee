@AlumNet.module 'JobExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Form extends Marionette.ItemView
    template: 'job_exchange/create/templates/form'

    initialize: (options)->
      document.title = 'AlumNet - Create a job'
      @current_user = options.user
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
      city_helper: if @model.get('city') then @model.get('city').text
      select_employment_type: (value)->
        if model.get('employment')
          if value == model.get('employment').value then "selected" else ""
      select_position_type: (value)->
        if model.get('position')
          if value == model.get('position').value then "selected" else ""

    ui:
      'submitLink': '.js-submit'
      'cancelLink': '.js-cancel'
      'selectCountries': '.js-countries'
      'selectCities': '.js-cities'
      'selectCompany': '#task-company'
      'selectProfindaMustHaveSkills': '#skills-must-have'
      'selectProfindaNiceHaveSkills': '#skills-nice-have'
      'selectProfindaMustHaveLanguages': '#languages-must-have'
      'selectProfindaNiceHaveLanguages': '#languages-nice-have'

    events:
      'click @ui.submitLink': 'submitClicked'
      'click @ui.cancelLink': 'cancelClicked'
      'change @ui.selectCountries': 'setCities'

    onShow: ->
      summernote_options =
        height: 100
        toolbar: [
          ['style', ['bold', 'italic', 'underline', 'clear']]
          ['para', ['ul', 'ol']]
        ]
      $('#task-description').summernote(summernote_options)
      $('#task-offer').summernote(summernote_options)

    onRender: ->
      ## set select2 to inputs
      @ui.selectCompany.select2
        placeholder: "Select a Company"
        data: []
      @ui.selectCities.select2
        placeholder: "Select a City"
        data: []
      data = CountryList.toSelect2()
      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: data
      @ui.selectProfindaMustHaveSkills.select2 @select2_profinda_options('alumnet_skills', @model.must_have_initial_values('alumnet_skills'))
      @ui.selectProfindaNiceHaveSkills.select2 @select2_profinda_options('alumnet_skills', @model.nice_have_initial_values('alumnet_skills'))
      @ui.selectProfindaMustHaveLanguages.select2 @select2_profinda_options('alumnet_languages', @model.must_have_initial_values('alumnet_languages'))
      @ui.selectProfindaNiceHaveLanguages.select2 @select2_profinda_options('alumnet_languages', @model.nice_have_initial_values('alumnet_languages'))

      ## set initial value
      unless @model.isNew()
        @ui.selectCountries.select2('val', @model.get('country').value)
        @setSelectCities(@model.get('country').value)

    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.must_have_list = [data.skills_must_have, data.languages_must_have].join(",").replace(/(^\s*,)|(,\s*$)/g, '')
      data.nice_have_list = [data.skills_nice_have, data.languages_nice_have].join(",").replace(/(^\s*,)|(,\s*$)/g, '')
      data.description = $('#task-description').code().replace(/<\/?[^>]+(>|$)/g, "")
      data.formatted_description = $('#task-description').code()
      data.offer = $('#task-offer').code()
      @model.save data,
        success: ->
          ##TODO Match
          AlumNet.trigger("program:job:my")
        error: (model, response, options)->
          $.growl.error({ message: response.responseJSON })

    cancelClicked: (e)->
      e.preventDefault()
      AlumNet.trigger("program:job:my")

    setCities: (e)->
      @setSelectCities(e.val)

    setSelectCities: (val)->
      if @model.get('city')
        initialValue = { id: @model.get('city').value, name: @model.get('city').text }
      else
        initialValue = false

      url = AlumNet.api_endpoint + '/countries/' + val + '/cities'
      @ui.selectCities.select2
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

    select2_profinda_options: (type, initial_data)->
      multiple: true
      placeholder: "Select"
      minimumInputLength: 2
      ajax:
        params:
          headers:
            "Accept": "application/vnd.profinda+json;version=1"
            "PROFINDAACCOUNTDOMAIN": AlumNet.profinda_account_domain
            "PROFINDAAPITOKEN": AlumNet.current_user.get('profinda_api_token')
        url: AlumNet.profinda_api_endpoint + "/autocomplete/dictionary_objects"
        method: 'GET'
        data: (term)->
            { term: term, type: type }
        results: (data, page) ->
          results:
            data
      formatResult: (data)->
        data.text
      formatSelection: (data)->
        data.text
      initSelection : (element, callback) ->
        callback(initial_data)