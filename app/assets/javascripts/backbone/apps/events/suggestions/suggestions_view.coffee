@AlumNet.module 'EventsApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Events extends AlumNet.EventsApp.Discover.EventView
    template: 'events/suggestions/templates/_event'

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
    template: 'events/suggestions/templates/layout'
    childView: Suggestions.Events
    childViewContainer: '.events-container'

    childViewOptions: ->
      collection: @collection

    initialize: (options)->
      @parentView = options.parentView
      @query = options.query

      @collection.fetch
        reset: true
        remove: true
        data: @query