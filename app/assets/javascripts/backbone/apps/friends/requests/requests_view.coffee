@AlumNet.module 'FriendsApp.Requests', (Requests, @AlumNet, Backbone, Marionette, $, _) ->
  class Requests.RequestView extends Marionette.ItemView
    template: 'friends/requests/templates/request'
    events:
      'click #js-accept-friendship':'clickedAccept'
    clickedAccept: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'accept'

  class Requests.RequestsView extends Marionette.CompositeView
    template: 'friends/requests/templates/requests_container'
    childView: Requests.RequestView
    childViewContainer: ".requests-list"
