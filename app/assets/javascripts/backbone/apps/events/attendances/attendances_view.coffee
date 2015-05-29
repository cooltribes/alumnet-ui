@AlumNet.module 'EventsApp.Attendances', (Attendances, @AlumNet, Backbone, Marionette, $, _) ->

  class Attendances.AttendanceView extends Marionette.ItemView
    template: 'events/attendances/templates/attendance'
    className: 'col-md-4 col-sm-6'
    initialize: (options)->
      @event = options.event


    templateHelpers: ->
      model = @model
      userIsAdmin: @event.userIsAdmin()
      statusText: ()->
        if(model.get('status')=='not_going')
          return "NOT\nATTENDING"
        if(model.get('status')=='going')
          return "ATTENDING"
        if(model.get('status')=='maybe')
          return "MAYBE"
        return "RSVP"

    ui:
      'removeLink': '#js-remove-attendance'

    events:
      'click @ui.removeLink': 'removeAttendance'

    removeAttendance: (e)->
      e.preventDefault()
      resp = confirm('Are you sure?')
      if resp
        @model.destroy()

  class Attendances.AttendancesView extends Marionette.CompositeView
    template: 'events/attendances/templates/attendances_container'
    childView: Attendances.AttendanceView
    childViewContainer: '.main-attendances-area'
    childViewOptions: ->
      event: @model

    initialize: ->
      @collection.getByStatus(1, {})
      document.title='AlumNet - '+@model.get('name')

    templateHelpers: ->
      userIsAdmin: @model.userIsAdmin()


    ui:
      'goingLink': '#js-going'
      'maybeLink': '#js-maybe'
      'invitedLink': '#js-invited'
      'notGoingLink': '#js-not-going'

    events:
      'click @ui.goingLink': 'goingClicked'
      'click @ui.maybeLink': 'maybeClicked'
      'click @ui.invitedLink': 'invitedClicked'
      'click @ui.notGoingLink': 'notGoingClicked'
      'click #js-invite-event': 'showInvite'

    showInvite: (e)->
      e.preventDefault()
      e.stopImmediatePropagation()
      current_user = AlumNet.current_user
      contacts = AlumNet.request('event:contacts', @model.id)
      AlumNet.trigger('user:event:invite', @model, contacts)

    goingClicked: (e)->
      e.preventDefault()
      target = $(e.currentTarget)
      @searchAttendances(1, target)

    maybeClicked: (e)->
      e.preventDefault()
      target = $(e.currentTarget)
      @searchAttendances(2, target)

    invitedClicked: (e)->
      e.preventDefault()
      target = $(e.currentTarget)
      @searchAttendances(0, target)

    notGoingClicked: (e)->
      e.preventDefault()
      target = $(e.currentTarget)
      @searchAttendances(3, target)

    searchAttendances: (status, target)->
      @collection.getByStatus(status, {})
      @clearClass()
      @setActiveClass(target)

    setActiveClass: (target)->
      target.addClass("sortingMenu__item__link sortingMenu__item__link--active")

    clearClass: ()->
      $('#js-invited, #js-going, #js-maybe, #js-not-going')
      .removeClass("sortingMenu__item__link sortingMenu__item__link--active")
      .addClass("sortingMenu__item__link sortingMenu__item__link")


