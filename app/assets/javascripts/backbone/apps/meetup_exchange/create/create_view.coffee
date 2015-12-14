@AlumNet.module 'MeetupExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Form extends Marionette.ItemView
    template: 'meetup_exchange/create/templates/form'

    initialize: (options)->
      document.title = 'AlumNet - Create a meetup'
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
      'datePickerArrival': '#task-arrival'
      'datePickerDeparture': '#task-until'
      'selectProfindaCountry': '#country'
      'selectProfindaCity': '#city'
      'selectProfindaAttributes': '#task-attributes'

    events:
      'click @ui.submitLink': 'submitClicked'
      'click @ui.cancelLink': 'cancelClicked'

    onShow: ->
      summernote_options =
        disableDragAndDrop: true
        height: 100
        toolbar: [
          ['style', ['bold', 'italic', 'underline', 'clear']]
          ['para', ['ul', 'ol']]
        ]
      $('#task-description').summernote(summernote_options)

    onRender: ->
      @ui.datePickerArrival.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        default_position: 'below'
      @ui.datePickerDeparture.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        default_position: 'below'
      @ui.selectProfindaCountry.select2 @select2_profinda_autocomplete('alumnet_country_residence', @model.country_initial_value())
      @ui.selectProfindaCity.select2 @select2_profinda_autocomplete('alumnet_city_residence', @model.city_initial_value())
      @ui.selectProfindaAttributes.select2 @select2_profinda_suggestions(@model.attributes_initial_values())

    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.must_have_list = data.country.replace(/(^\s*,)|(,\s*$)/g, '')
      data.nice_have_list = [data.city, data.task_attributes].join(",").replace(/(^\s*,)|(,\s*$)/g, '')
      data.description = $('#task-description').summernote('code').replace(/<\/?[^>]+(>|$)/g, "")
      data.formatted_description = $('#task-description').summernote('code')
      @model.save data,
        success: ->
          ##TODO Match
          AlumNet.trigger("program:meetup:my")
        error: (model, response, options)->
          $.growl.error({ message: response.responseJSON })

    cancelClicked: (e)->
      e.preventDefault()
      AlumNet.trigger("program:meetup:my")

    select2_profinda_suggestions: (initial_data)->
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
            { term: term }
        results: (data, page) ->
          results:
            data
      formatResult: (data)->
        data.value +  " - " + data.name
      formatSelection: (data)->
        data.value
      initSelection: (element, callback)->
        callback(initial_data)

    select2_profinda_autocomplete: (type, initial_data)->
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