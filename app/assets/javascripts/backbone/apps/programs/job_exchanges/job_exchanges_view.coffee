@AlumNet.module 'ProgramsApp.JobExchange', (JobExchange, @AlumNet, Backbone, Marionette, $, _) ->
  class JobExchange.Empty extends Marionette.ItemView
    template: 'programs/job_exchanges/templates/empty'
  
  class JobExchange.Task extends Marionette.ItemView
    className: 'col-md-4 no-padding-rigth'

    initialize: (options)->
      @mode = options.mode

    getTemplate: ->
      if @mode == 'detail'
        'programs/job_exchanges/templates/detail_task'
      else if @mode == 'discover'
        'programs/job_exchanges/templates/discover_task'
      else
        'programs/job_exchanges/templates/my_task'

    templateHelpers: ->
      model = @model
      canInvite: @model.canInvite()
      canEdit: @model.canEdit()
      canDelete: @model.canDelete()
      canApply: @model.canApply()
      location: ->
        location = []
        location.push model.get('country').text unless model.get('country').text == ""
        location.push model.get('city').text unless model.get('city').text == ""
        location.join(', ')
    ui:
      'deleteLink': '.js-job-delete'
      'refreshLink': '.js-job-refresh'
      'applyLink':'.js-job-apply'
      'inviteLink':'.js-job-invite'

    events:
      'click @ui.deleteLink': 'deleteClicked'
      'click @ui.refreshLink': 'refreshClicked'
      'click @ui.applyLink': 'applyClicked'
      'click @ui.inviteLink': 'inviteClicked'

    inviteClicked: (e)->
      e.preventDefault()
      user_id = $(e.currentTarget).data('user')
      task_id = $(e.currentTarget).data('task')
      invite = new AlumNet.Entities.TaskInvitation
      invite.save { user_id: user_id, task_id: task_id },
        success: ->
          $(e.currentTarget).remove()

    applyClicked: (e)->
      e.preventDefault()
      view = @
      Backbone.ajax
        url: AlumNet.api_endpoint + '/job_exchanges/' + @model.id + '/apply'
        method: 'PUT'
        success: ->
          view.model.set('user_can_apply', false)
          view.render()

    refreshClicked: (e)->
      e.preventDefault()
      view = @
      @model.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/' + @model.id + '/matches'
        success: ->
          view.render()

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm('Are you sure?')
      if resp
        @model.destroy()

  class JobExchange.TaskInvitation extends Marionette.ItemView
    template: 'programs/job_exchanges/templates/invitation'

    ui:
      'linkAccept': '.js-invitation-accept'
      'linkDecline': '.js-invitation-decline'

    events:
      'click @ui.linkAccept': 'acceptClicked'
      'click @ui.linkDecline': 'declineClicked'

    templateHelpers: ->
      model = @model
      location: ->
        location = []
        task = model.get('task')
        if task
          location.push task.country.text unless task.country.text == ""
          location.push task.city.text unless task.city.text == ""
          location.join(', ')

    acceptClicked: (e)->
      e.preventDefault()
      view = @
      @model.save {},
        success: ->
          view.destroy()

    declineClicked: (e)->
      e.preventDefault()
      @model.destroy()

  class JobExchange.TaskInvitations extends Marionette.CompositeView
    template: 'programs/job_exchanges/templates/invitations'
    childView: JobExchange.TaskInvitation
    childViewContainer: '.invitations-container'
    emptyView: JobExchange.Empty

  class JobExchange.MyJobs extends Marionette.CompositeView
    template: 'programs/job_exchanges/templates/my_jobs'
    childView: JobExchange.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    emptyView: JobExchange.Empty

  class JobExchange.AppliedJobs extends Marionette.CompositeView
    template: 'programs/job_exchanges/templates/applied'
    childView: JobExchange.Task
    childViewContainer: '.tasks-container'
    childViewOptions:
      mode: 'discover'
    emptyView: JobExchange.Empty

  class JobExchange.DiscoverJobs extends Marionette.CompositeView
    template: 'programs/job_exchanges/templates/discover'
    childView: JobExchange.Task
    childViewContainer: '.tasks-container'
    childViewOptions:
      mode: 'discover'
    emptyView: JobExchange.Empty

  class JobExchange.AutomatchesJobs extends Marionette.CompositeView
    template: 'programs/job_exchanges/templates/automatches'
    childView: JobExchange.Task
    childViewContainer: '.tasks-container'
    childViewOptions:
      mode: 'discover'
    emptyView: JobExchange.Empty

  class JobExchange.Form extends Marionette.ItemView
    template: 'programs/job_exchanges/templates/form'

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
      'selectProfindaSkills': '.js-profinda-skills'
      'selectProfindaLanguages': '.js-profinda-languages'

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
      @ui.selectProfindaSkills.select2 @select2_profinda_options('alumnet_skills')
      @ui.selectProfindaLanguages.select2 @select2_profinda_options('alumnet_languages')

      ## set initial value
      unless @model.isNew()
        @ui.selectCountries.select2('val', @model.get('country').value)
        @setSelectCities(@model.get('country').value)


    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.must_have_list = data.skills_must_have + "," + data.languages_must_have
      data.nice_have_list = data.skills_nice_have + "," + data.languages_nice_have
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