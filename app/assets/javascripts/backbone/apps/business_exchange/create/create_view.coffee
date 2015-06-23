@AlumNet.module 'BusinessExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Form extends Marionette.ItemView
    template: 'business_exchange/create/templates/form'

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
      is_new: @model.isNew()

    ui:
      'submitLink': '.js-submit'
      'cancelLink': '.js-cancel'
      'selectProfindaSkills': '.js-profinda-skills'
      'selectProfindaLanguages': '.js-profinda-languages'
      'selectProfindaLocation': '.js-profinda-location'
      'selectProfindaSectors': '.js-profinda-sectors'
      'selectProfindaBrands': '.js-profinda-brands'
      'datePickerDeadline': '#task-until'

    events:
      'click @ui.submitLink': 'submitClicked'
      'click @ui.cancelLink': 'cancelClicked'

    onRender: ->
      @ui.datePickerDeadline.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        default_position: 'below'
      @ui.selectProfindaSkills.select2 @select2_profinda_options('alumnet_skills')
      @ui.selectProfindaLanguages.select2 @select2_profinda_options('alumnet_languages')
      @ui.selectProfindaLocation.select2 @select2_profinda_options('alumnet_location')
      @ui.selectProfindaSectors.select2 @select2_profinda_options('alumnet_sectors')
      @ui.selectProfindaBrands.select2 @select2_profinda_options('alumnet_brands')



    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.must_have_list = [data.skills_must_have, data.languages_must_have,
        data.location_must_have, data.sectors_must_have, data.brands_must_have].join(",")
      data.nice_have_list = [data.skills_nice_have, data.languages_nice_have,
        data.location_nice_have, data.sectors_nice_have, data.brands_nice_have].join(",")
      @model.save data,
        success: ->
          ##TODO Match
          AlumNet.trigger("program:business:my")
        error: (model, response, options)->
          $.growl.error({ message: response.responseJSON })

    cancelClicked: (e)->
      e.preventDefault()
      AlumNet.trigger("program:business:my")

    select2_profinda_options: (type)->
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