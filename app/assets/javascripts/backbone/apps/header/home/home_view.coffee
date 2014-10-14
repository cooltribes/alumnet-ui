@AlumNet.module 'HeaderApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->

  ###class Home.Group extends Marionette.ItemView
    template: 'header/home/templates/group'
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
      alert this.model.escape('description')
    deleteClicked: (e)->
      e.stopPropagation()
      this.trigger('group:delete', this.model)
    showClicked: (e)->
      e.preventDefault()
      e.stopPropagation()
      this.trigger('group:show', this.model)###


  class Home.Header extends Marionette.CompositeView
    className: 'ng-scope'
    template: 'header/home/templates/header_container'
    ###childView: Home.Group
    childViewContainer: ".group-container"###
    # onChildviewGroupDelete: ->
    #   console.log "ahoy"