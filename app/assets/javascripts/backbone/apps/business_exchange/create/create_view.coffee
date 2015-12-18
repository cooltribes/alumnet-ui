@AlumNet.module 'BusinessExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Form extends Marionette.ItemView
    template: 'business_exchange/create/templates/form'

    initialize: (options)->
      document.title = 'AlumNet - Create a Task'
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
      'datePickerDeadline': '#task-until'
      'selectProfindaMustHaveList': '#must-have-list'
      'selectProfindaNiceHaveList': '#nice-have-list'

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
      @ui.datePickerDeadline.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        default_position: 'below'
      @ui.selectProfindaMustHaveList.select2 @select2_profinda_options(@model.must_have_initial_values())
      @ui.selectProfindaNiceHaveList.select2 @select2_profinda_options(@model.nice_have_initial_values())



    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.must_have_list = data.must_have_list.replace(/(^\s*,)|(,\s*$)/g, '')
      data.nice_have_list = data.nice_have_list.replace(/(^\s*,)|(,\s*$)/g, '')
      data.description = $('#task-description').summernote('code').replace(/<\/?[^>]+(>|$)/g, "")
      data.formatted_description = $('#task-description').summernote('code')
      @model.save data,
        success: ->
          ##TODO Match
          AlumNet.trigger("program:business:my")
        error: (model, response, options)->
          $.growl.error({ message: response.responseJSON })

    cancelClicked: (e)->
      e.preventDefault()
      AlumNet.trigger("program:business:my")

    select2_profinda_options: (initial_data)->
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