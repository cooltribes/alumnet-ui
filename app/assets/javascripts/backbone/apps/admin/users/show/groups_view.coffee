@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Group extends Marionette.ItemView
    template: 'admin/users/show/templates/_group'
    className: 'container-fluid col-md-3'

  class UserShow.Groups extends Marionette.CompositeView
    template: 'admin/users/show/templates/groups'
    #className: 'container'
    childView: UserShow.Group
    childViewContainer: '#js-groups-container'
    childViewOptions: ->
      user: @model

    ui:
      'inputSearch': '#groups-search'
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