@AlumNet.module 'ProgramsApp.JobExchange', (JobExchange, @AlumNet, Backbone, Marionette, $, _) ->

  class JobExchange.Task extends Marionette.ItemView
    template: 'programs/job_exchanges/templates/task'

    templateHelpers: ->
      canEdit: @model.canEdit()
      canDelete: @model.canDelete()

    ui:
      'deleteLink': '.js-job-delete'

    events:
      'click @ui.deleteLink': 'DeleteClicked'

    DeleteClicked: (e)->
      e.preventDefault()
      resp = confirm('Are you sure?')
      if resp
        @model.destroy()

  class JobExchange.MyJobs extends Marionette.CompositeView
    template: 'programs/job_exchanges/templates/my_jobs'
    childView: JobExchange.Task
    childViewContainer: '.tasks-container'

  class JobExchange.Form extends Marionette.ItemView
    template: 'programs/job_exchanges/templates/form'

    initialize: (options)->
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
      city_helper: if @model.get('city') then @model.get('city').text

    ui:
      'submitLink': '.js-submit'
      'cancelLink': '.js-cancel'
      'selectCountries': '.js-countries'
      'selectCities': '.js-cities'
      'selectCompany': '#task-company'
      'selectProfindaObjects': '.js-profinda-object'

    events:
      'click @ui.submitLink': 'submitClicked'
      'click @ui.cancelLink': 'cancelClicked'
      'change @ui.selectCountries': 'setCities'

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
      @ui.selectProfindaObjects.select2 @select2_profinda_options()

      ## set initial value
      unless @model.isNew()
        @ui.selectCountries.select2('val', @model.get('country').value)
        @setSelectCities(@model.get('country').value)


    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @model.save data,
        success: ->
          ##TODO Match
          console.log "Ok"
        error: (model, response, options)->
          $.growl.error({ message: response.responseJSON })

    cancelClicked: (e)->
      e.preventDefault()
      console.log 'cancel'

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

    select2_profinda_options: ->
      multiple: true
      placeholder: "Select"
      minimumInputLength: 2
      ajax:
        params:
          headers:
            "Accept": "application/vnd.profinda+json;version=1"
            "PROFINDAACCOUNTDOMAIN": AlumNet.profinda_account_domain
            "PROFINDAAPITOKEN": AlumNet.current_user.get('profinda_api_token')
        url: AlumNet.profinda_api_endpoint + "/autocomplete/suggestions"
        method: 'GET'
        data: (term)->
            term: term
        results: (data, page) ->
          results:
            data
      formatResult: (data)->
        data.value
      formatSelection: (data)->
        data.value
