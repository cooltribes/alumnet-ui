@AlumNet.module 'EventsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->

  class Create.EventForm extends Marionette.ItemView
    template: 'events/create/templates/form'

    initialize:(options)->
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
      user_name: @user.get('name')
      userIsAdmin: @user.isAlumnetAdmin()

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

    changedAdmissionType: (e)->
      if(@ui.admissionType.val() == "1")
        @ui.pricesContainer.removeClass('hide')
      else if(@ui.admissionType.val() == "0")
        @ui.pricesContainer.addClass('hide')

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
      AlumNet.trigger 'events:discover'

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
        onSelect: (date, standarDate, jsDate, input)->
          $("#event-end-date").val(date)
          
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



  # INVITE

  class Create.UserView extends Marionette.ItemView
    template: 'events/create/templates/user'
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
      @ui.infoUser.removeClass('col-md-7').addClass('col-md-6')
      @ui.invitationBox.removeClass('col-md-2').addClass('col-md-3')
      @ui.inviteLink.remove()
      @ui.invitation.html('<span>Sending request <span class="glyphicon glyphicon-time"></span> </span>')
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
      @ui.invitation.html('<span>Invited <span class="glyphicon glyphicon-ok"></span> </span>')

  class Create.UsersView extends Marionette.CompositeView
    template: 'events/create/templates/users_container'
    childView: Create.UserView
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
       
