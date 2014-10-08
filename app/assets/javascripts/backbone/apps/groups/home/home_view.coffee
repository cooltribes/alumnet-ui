@AlumNet.module 'GroupsApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->

  class Home.Group extends Marionette.ItemView
    template: "#row-table"
    tagName: 'tr'
    events:
      'click td': 'showDescription'
      'click .js-delete': 'deleteClicked'
      'click .js-show': 'showClicked'
    remove: ->
      self = this
      this.$el.fadeOut ->
        Marionette.ItemView.prototype.remove.call(self)
    showDescription: ->
      console.log "on model:", this.model
      alert this.model.escape('description')
    deleteClicked: (e)->
      e.stopPropagation()
      this.trigger('group:delete', this.model)
    showClicked: (e)->
      e.preventDefault()
      e.stopPropagation()
      this.trigger('group:show', this.model)


  class Home.Groups extends Marionette.CompositeView
    template: "#table"
    childView: Home.Group
    childViewContainer: "tbody"
    # onChildviewGroupDelete: ->
    #   console.log "ahoy"