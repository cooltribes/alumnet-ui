@AlumNet.module 'EventsApp.Attendances', (Attendances, @AlumNet, Backbone, Marionette, $, _) ->

  class Attendances.AttendanceView extends Marionette.ItemView
    template: 'events/attendances/templates/attendance'
    className: 'col-md-4 col-sm-6'
    templateHelpers: ->
      model=@model
      statusText: ()->
        if(model.get('status')=='not_going')
          return "NOT\nATTENDING"
        if(model.get('status')=='going')
          return "ATTENDING"
        if(model.get('status')=='maybe')
          return "INVITED"
        return "INVITED"

  class Attendances.AttendancesView extends Marionette.CompositeView
    template: 'events/attendances/templates/attendances_container'
    childView: Attendances.AttendanceView
    childViewContainer: '.main-attendances-area'
    initialize: ->
      @collection.getByStatus(1, {})

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


