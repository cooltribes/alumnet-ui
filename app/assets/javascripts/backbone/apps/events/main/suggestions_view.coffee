@AlumNet.module 'EventsApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Events extends AlumNet.EventsApp.Discover.EventView
    template: 'events/main/templates/_event_suggested'

    templateHelpers: ->
      model = @model
      location: @model.getLocation()
      isPast: @model.isPast()
      isOpen: @model.isOpen()
      userCanAttend: @model.userCanAttend()
      select: (value, option)->
        if value == option then "selected" else ""
      attendance_status: ->
        attendance_info = model.get('attendance_info')
        if attendance_info
          attendance_info.status
        else
          null

  class Suggestions.EventsView extends Marionette.CompositeView
    template: 'events/main/templates/suggestions_container'
    childView: Suggestions.Events
    childViewContainer: '.events-container'

    childViewOptions: ->
      collection: @collection

    initialize: (options)->
      @optionsMenuLeft = options.optionMenuLeft
      @parentView = options.parentView
      @query = options.query

      @collection.fetch
        reset: true
        remove: true
        data: @query

    templateHelpers: ->
      showDiscover: @showButtonDiscover()

    showButtonDiscover: ->
      if @optionsMenuLeft == "discoverEvents"
        showDiscover = true
      else
        showDiscover = false
