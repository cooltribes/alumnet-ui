@AlumNet.module 'GroupsApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->

  class Home.Group extends Marionette.ItemView
    template: 'groups/home/templates/row'
    className: 'col-md-4 group'
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
    className: 'container-fluid'
    template: 'groups/home/templates/table'
    childView: Home.Group
    childViewContainer: ".group-container"
    # onChildviewGroupDelete: ->
    #   console.log "ahoy"