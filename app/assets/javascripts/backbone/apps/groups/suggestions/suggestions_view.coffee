@AlumNet.module 'GroupsApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Group extends Marionette.ItemView
    template: 'groups/suggestions/templates/_group'

    events:
      'click .js-join':'sendJoin'

    sendJoin: (e)->
      e.preventDefault()
      @trigger 'join'
      model = @model
      @model.fetch
        success: ->
          model.trigger('renderView')
      @render()
      @trigger 'Catch:Up'

    templateHelpers: ->
      userIsMember: @model.userIsMember()

  class Suggestions.GroupsView extends Marionette.CompositeView
    template: 'groups/suggestions/templates/layout'
    childView: Suggestions.Group
    childViewContainer: '.groups-container'