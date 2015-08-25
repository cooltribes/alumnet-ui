@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Event extends Marionette.ItemView
    template: 'admin/users/show/templates/_overview_event'
    className: 'container-fluid col-md-3'

    templateHelpers: ->
      location: @model.getLocation()
      date: moment(@model.get('start_date')).format('DD MMM YYYY')

  class UserShow.Events extends Marionette.CompositeView
    template: 'admin/users/show/templates/events'
    #className: 'container'
    childView: UserShow.Event
    childViewContainer: '#js-events-container'
    childViewOptions: ->
      user: @model

    ui:
      'inputSearch': '#events-search'
      'searchLink': '#js-search'

    events:
      'click @ui.searchLink': 'searchClicked'

    searchClicked: (e)->
      e.preventDefault()
      term = @ui.inputSearch.val()
      view = @
      @collection.fetch
        data: { q: { name_cont: term } }
        success: ->
          view.render()