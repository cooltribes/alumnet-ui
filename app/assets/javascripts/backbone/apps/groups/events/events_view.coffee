@AlumNet.module 'GroupsApp.Events', (Events, @AlumNet, Backbone, Marionette, $, _) ->
  class Events.EmptyView extends Marionette.ItemView
    template: 'groups/events/templates/empty'

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
      group_official: @group.get('official')

    ui:
      'startDate':'#event-start-date'
      'endDate':'#event-end-date'
      'startHour':'#event-start-hour'
      'endHour':'#event-end-hour'
      'selectCountries':'.js-countries'
      'selectCities':'.js-cities'
      'selectInvitationProcess': '#invitation-process'
      'official': '#official'
      'admissionTypeContainer': '#admission-type-container'
      'admissionType': '#admission-type'
      'pricesContainer': '#prices-container'
      'regularPrice': '#event-regular-price'
      'premiumPrice': '#event-premium-price'

    events:
      'click button.js-submit': 'submitClicked'
      'click button.js-cancel': 'cancelClicked'
      'change #event-cover': 'previewImage'
      'change .js-countries': 'setCities'
      'change #event-type': 'changedGroupType'
      'change #official': 'changedOfficial'
      'change #admission-type': 'changedAdmissionType'

    changedGroupType: (e)->
      select = $(e.currentTarget)
      @ui.selectInvitationProcess.html(@invitationOptionsString(select.val()))

    changedOfficial: (e)->
      if(@ui.official.val() == "1")
        @ui.admissionTypeContainer.removeClass('hide')
        if(@ui.admissionType.val() == "1")
          @ui.pricesContainer.removeClass('hide')
      else if(@ui.official.val() == "0")
        @ui.admissionTypeContainer.addClass('hide')
        @ui.pricesContainer.addClass('hide')
        @ui.admissionType.val('0')
        @ui.regularPrice.val('')
        @ui.premiumPrice.val('')

    changedAdmissionType: (e)->
      if(@ui.admissionType.val() == "1")
        @ui.pricesContainer.removeClass('hide')
      else if(@ui.admissionType.val() == "0")
        @ui.pricesContainer.addClass('hide')
        @ui.regularPrice.val('')
        @ui.premiumPrice.val('')

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
        show_icon: false
        show_select_today: false
        pair: @ui.endDate

      @ui.endDate.Zebra_DatePicker
        direction: true
        show_icon: false
        show_select_today: false

      @ui.startHour.clockpicker
        donetext: 'Select'
        autoclose: true
      @ui.endHour.clockpicker
        donetext: 'Select'
        autoclose: true

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
    className: ''

    initialize: (options)->
      @collection =  options.collection

    templateHelpers: ->
      model = @model
      location: @model.getLocation()
      userIsAdmin: @model.userIsAdmin()
      userCanAttend: @model.userCanAttend()
      isPast: @model.isPast()
      select: (value, option)->
        if value == option then "selected" else ""
      attendance_status: ->
        attendance_info = model.get('attendance_info')
        if attendance_info
          attendance_info.status
        else
          null
    ui:
      attendanceStatus: '#attendance-status'
      linkCancel: '#js-attendance-cancel'

    events:
      'change @ui.attendanceStatus': 'changeAttendanceStatus'
      'click @ui.linkCancel': 'cancelEvent'

    cancelEvent: (e)->
      e.preventDefault()
      resp = confirm "Are you sure?"
      if resp
        collection = @collection
        model = @model
        Backbone.ajax
          url: @model.url()
          method: 'DELETE'
          success: (data, textStatus, xhr)->
            collection.remove(model)
          error: (xhr, textStatus, error)->
            if xhr.status == 409
              alert xhr.responseJSON.message

    changeAttendanceStatus: (e)->
      e.preventDefault()
      status = $(e.currentTarget).val()
      attendance = @model.attendance
      if status
        if attendance.isNew()
          attrs = { user_id: AlumNet.current_user.id, event_id: @model.id, status: status }
          attendance.save(attrs)
        else
          attendance.set('status', status)
          attendance.save()
      if status=='going'
        $('#attendance-status').css('background-color','#72da9e')
      if status=='invited'
        $('#attendance-status').css('background-color','#6dc2e9')
      if status=='not_going'
        $('#attendance-status').css('background-color','#ea7952')
      if status=='maybe'
        $('#attendance-status').css('background-color','#f5ac45')

  class Events.EventsView extends Marionette.CompositeView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'groups/events/templates/events_container'
    childView: Events.EventView
    emptyView: Events.EmptyView
    childViewContainer: ".main-events-area"

    childViewOptions: ->
      collection: @collection

    initialize: ->
      @searchUpcomingEvents({})
      $(".navTopBar__left__item")
        .removeClass "navTopBar__left__item--active"
      $('#eventsLayoutOption').addClass "navTopBar__left__item--active"

    templateHelpers: ->
      userIsMember: @model.userIsMember()

    ui:
      'upcomingEvents':'#js-upcoming-events'
      'pastEvents':'#js-past-events'
      'searchInput':'#js-search-input'

    events:
      'click @ui.upcomingEvents': 'clickUpcoming'
      'click @ui.pastEvents': 'clickPast'
      'keypress @ui.searchInput': 'searchEvents'

    clickUpcoming: (e)->
      e.preventDefault()
      @searchUpcomingEvents({})
      @clearClass()
      @setActiveClass($(e.currentTarget))


    clickPast: (e)->
      e.preventDefault()
      @searchPastEvents({})
      @clearClass()
      @setActiveClass($(e.currentTarget))

    searchUpcomingEvents: (query)->
      @collection.getUpcoming(query)
      @flag = "upcoming"

    searchPastEvents: (query)->
      @collection.getPast(query)
      @flag = "past"


    searchEvents: (e)->
      if e.which == 13
        unless @ui.searchInput.val() == ""
          query = { name_cont: @ui.searchInput.val() }
        else
          query = {}
        if @flag == "upcoming"
          @searchUpcomingEvents(query)
        else
          @searchPastEvents(query)

    setActiveClass: (target)->
      target.addClass("sortingMenu__item__link sortingMenu__item__link--active")

    clearClass: ()->
      $('#js-upcoming-events, #js-past-events')
      .removeClass("sortingMenu__item__link sortingMenu__item__link--active")
      .addClass("sortingMenu__item__link sortingMenu__item__link")

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
