@AlumNet.module 'FriendsApp.Filters', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  class Filters.FriendsView extends Marionette.CompositeView
    template: 'friends/filters/templates/layout'