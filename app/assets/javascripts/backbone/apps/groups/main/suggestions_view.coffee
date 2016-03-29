@AlumNet.module 'GroupsApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Group extends Marionette.ItemView
    template: 'groups/main/templates/_group_suggested'

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

  class Suggestions.GroupsView extends Marionette.CompositeView
    template: 'groups/main/templates/suggestions_container'
    childView: Suggestions.Group
    childViewContainer: '.groups-container'