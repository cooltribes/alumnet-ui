@AlumNet.module 'JobExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.CompanyModal extends Backbone.Modal
    template: 'job_exchange/create/templates/company_modal'
    cancelEl: '#cancel'

    initialize: (options)->
      @taskView = options.taskView
      Backbone.Validation.bind this,
      valid: (view, attr, selector) ->
        view.clearErrors(attr)
      invalid: (view, attr, error, selector) ->
        view.addErrors(attr, error)

    events:
      'click #save': 'saveClicked'

    templateHelpers: ->
      model = @model
      sizes_options: (item)->
        model.sizes_options(item)

    onRender: ->
      $selectSectors = @$('#sectors')
      @$('#size').select2()
      Backbone.ajax
        url: AlumNet.api_endpoint + '/sectors'
        success: (data)->
          $selectSectors.select2
            data: { results: data, text: "name" }

    clearErrors: (attr)->
      $el = @$("[name=#{attr}]")
      $group = $el.closest('.form-col')
      $group.removeClass('has-error')
      $group.find('.help-block').html('').addClass('hidden')

    addErrors: (attr, error)->
      $el = @$("[name=#{attr}]")
      $group = $el.closest('.form-col')
      $group.addClass('has-error')
      $group.find('.help-block').html(error).removeClass('hidden')

    saveClicked: (e)->
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      @model.set(data)
      if @model.isValid(true)
        @model.save {},
          success: (model)->
            initialValue = { id: model.id, name: model.get('name') }
            view.destroy()
            view.ui.showModalLink.hide()
            view.taskView.selectCompany view.taskView.ui.selectCompany, initialValue
          error: (model, response)->
            errors = response.responseJSON
            _.each errors, (value, key, list)->
              view.clearErrors(key)
              view.addErrors(key, value[0])


  class Create.Form extends Marionette.ItemView
    template: 'job_exchange/create/templates/form'

    initialize: (options)->
      document.title = 'AlumNet - Post a job'
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
      applicationType: @model.get('application_type')
      urlType: @model.get('external_url')
      city_helper: if @model.get('city') then @model.get('city').id
      company_helper: if @model.get('company') then @model.get('company').text
      seniorities:()->
        seniorities = new AlumNet.Utilities.Seniorities
        seniorities.fetch()
        seniorities.results

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
      'selectPosition': '#employment-type'
      'showModalLink': '#js-show-modal'
      'applicationType': '.js-application-type'
      'externalUrl': '#external_url'

    events:
      'click @ui.submitLink': 'submitClicked'
      'click @ui.cancelLink': 'cancelClicked'
      'change @ui.selectCountries': 'setCities'
      'click @ui.showModalLink': 'showCompanyModal'
      'change @ui.applicationType': 'changeApplicationType'

    onShow: ->
      summernote_options =
        height: 100
        toolbar: [
          ['style', ['bold', 'italic', 'underline', 'clear']]
          ['para', ['ul', 'ol']]
        ]

      summernote_options_description =
        height: 200
        toolbar: [
          ['style', ['bold', 'italic', 'underline', 'clear']]
          ['para', ['ul', 'ol']]
        ]

      $('#task-description').summernote(summernote_options_description)
      $('#task-offer').summernote(summernote_options)

    onRender: ->
      @selectCompany(@ui.selectCompany)

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
        @ui.selectCountries.select2('val', @model.get('country').id)
        @setSelectCities(@model.get('country').id)

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

    selectCompany: (element, initialValue)->
      view = @
      Backbone.ajax
        url: AlumNet.api_endpoint + "/companies/all"
        success: (data)->
          element.select2
            placeholder: "Select a Company"
            data: { results: data, text: "name" }
            formatNoMatches: ->
              view.ui.showModalLink.show()
              "No matches"
            formatSearching: ->
              view.ui.showModalLink.hide()
              "Searching..."
          if initialValue
            element.select2('data', initialValue)
          else if view.model.get('company')
            company = view.model.get('company')
            element.select2('data', { id: company.value, name: company.text })

    setSelectCities: (val)->
      if @model.get('city')
        initialValue = { id: @model.get('city').id, name: @model.get('city').name }
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

    showCompanyModal: (e)->
      e.preventDefault()
      modal = new Create.CompanyModal
        model: new AlumNet.Entities.Company
        taskView: @
      $('#js-modal-company-container').html(modal.render().el)

    changeApplicationType: (e)->
      if e.target.value == 'external'
        $('#external_url').prop("disabled", false)
      else
        $('#external_url').prop("disabled", true)

  class Create.JobPostsView extends Marionette.ItemView
    template: 'job_exchange/create/templates/job_posts'
    className: 'container'

    initialize: (options)->
      document.title = 'AlumNet - Post a job'

    ui:
      'modalMembers':'#js-modal'

    events:
      'click @ui.modalMembers': 'showModal'
      'click button.js-submit': 'submitClicked'
      'click .js-item': 'startPayment'

    showModal: (e)->
      e.preventDefault()
      modal = new Create.ModalOnboarding
      $('#container-modal-members').html(modal.render().el)

    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      AlumNet.trigger 'payment:checkout' , data, 'job_post'

    startPayment: (e)->
      e.preventDefault()
      data = {"subscription_id": e.target.id}
      AlumNet.trigger 'payment:checkout', data, 'job_post'

  class Create.ModalOnboarding extends Backbone.Modal
    template: 'job_exchange/create/templates/modal'
    cancelEl: '#js-close'
