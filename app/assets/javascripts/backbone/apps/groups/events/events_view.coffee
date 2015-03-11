@AlumNet.module 'GroupsApp.Events', (Events, @AlumNet, Backbone, Marionette, $, _) ->

  class Events.EventForm extends Marionette.ItemView
    template: 'groups/events/templates/form'

    initialize:(options)->
      @group = options.group
      @user = options.user
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
      group_name: @group.get('name')
      userIsAdmin: @user.isAlumnetAdmin()
      groupCanHaveOfficialSubgroup: @group.canHaveOfficialSubgroup()

    ui:
      'startDate':'#event-start-date'
      'endDate':'#event-end-date'
      'startHour':'#event-start-hour'
      'endHour':'#event-end-hour'
      'selectCountries':'.js-countries'
      'selectCities':'.js-cities'
      'selectInvitationProcess': '#invitation-process'

    events:
      'click button.js-submit': 'submitClicked'
      'click button.js-cancel': 'cancelClicked'
      'change #event-cover': 'previewImage'
      'change .js-countries': 'setCities'
      'change #event-type': 'changedGroupType'

    changedGroupType: (e)->
      select = $(e.currentTarget)
      @ui.selectInvitationProcess.html(@invitationOptionsString(select.val()))

    invitationOptionsString: (option)->
      if option == "closed"
        '<option value="1">All Members can invite, but the admins approved</option>
        <option value="2">Only the admins can invite</option>'
      else if option == "secret"
        '<option value="2">Only the admins can invite</option>'
      else
        '<option value="0">All Members can invite</option>
        <option value="1">All Members can invite, but the admins approved</option>
        <option value="2">Only the admins can invite</option>'

    setCities: (e)->
      url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
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

    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#event-cover')
      formData.append('cover', file[0].files[0])
      @model.set(data)
      @trigger 'form:submit', @model, formData

    cancelClicked: (e)->
      e.preventDefault()
      AlumNet.trigger 'groups:posts', @group.id

    previewImage: (e)->
      input = @.$('#event-cover')
      preview = @.$('#preview-cover')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    onRender: ->
      #Datepickers
      @ui.startDate.Zebra_DatePicker
        direction: true
        show_icon: false
        show_select_today: false
        pair: @ui.endDate

      @ui.endDate.Zebra_DatePicker
        direction: 1
        show_icon: false
        show_select_today: false

      @ui.startHour.clockpicker
        donetext: 'Select'
      @ui.endHour.clockpicker
        donetext: 'Select'

      #Select Locations
      @ui.selectCities.select2
        placeholder: "Select a City"
        data: []
      data = CountryList.toSelect2()
      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: data

  class Events.EventView extends Marionette.ItemView
    template: 'groups/events/templates/event'
    className: 'col-md-4 col-sm-6 col-xs-12'

    templateHelpers: ->
      location: @model.getLocation()
      select: (value, option)->
        if value == option then "selected" else ""
    ui:
      attendanceStatus: '#attendance-status'

    events:
      'change @ui.attendanceStatus': 'changeAttendanceStatus'

    changeAttendanceStatus: (e)->
      e.preventDefault()
      status = $(e.currentTarget).val()
      if status
        attendance = @model.attendance
        attendance.set('status', status)
        attendance.save()

  class Events.EventsView extends Marionette.CompositeView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'groups/events/templates/events_container'
    childView: Events.EventView
    childViewContainer: ".main-events-area"
    templateHelpers: ->
      userCanCreateSubGroup: @model.canDo('create_subgroup')

  # INVITE

  class Events.UserView extends Marionette.ItemView
    template: 'groups/events/templates/user'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'
    initialize: (options)->
      @event = options.event
    templateHelpers: ->
      model = @model
      wasInvited: ->
        model.get('attendance_info')

    ui:
      invitation: '.invitation'
      inviteLink: 'a.js-invite'
      infoUser: '#js-info-user'
      invitationBox: '#js-invitation-box'

    events:
      'click @ui.inviteLink': 'clickedInvite'

    clickedInvite: (e)->
      e.preventDefault()
      attr = {user_id: @model.id, event_id: @event.id}
      attendance = AlumNet.request('attendance:new')
      view = @
      attendance.save attr,
        success: (model, response, options)->
          view.removeLink()

    removeLink: ->
      @ui.infoUser.removeClass('col-md-7').addClass('col-md-6')
      @ui.invitationBox.removeClass('col-md-2').addClass('col-md-3')
      @ui.inviteLink.remove()
      @ui.invitation.append('<span>Invited <span class="glyphicon glyphicon-ok"></span> </span>')

  class Events.UsersView extends Marionette.CompositeView
    template: 'groups/events/templates/users_container'
    childView: Events.UserView
    childViewContainer: ".users-list"
    childViewOptions: ->
      event: @model

    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      this.trigger('users:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        profile_first_name_cont: searchTerm
        profile_last_name_cont: searchTerm
        email_cont: searchTerm
