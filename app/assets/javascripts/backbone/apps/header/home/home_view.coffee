@AlumNet.module 'HeaderApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->

  class Home.MenuItem extends Marionette.ItemView
    template: 'header/home/templates/item'
    tagName: 'li'
    events:
      'click a': 'itemClicked'      
    itemClicked: ->
      #alert @model.escape('icon-class')
    ###remove: ->
      self = this
      this.$el.fadeOut ->
        Marionette.ItemView.prototype.remove.call(self)
    deleteClicked: (e)->
      e.stopPropagation()
      this.trigger('group:delete', this.model)
    showClicked: (e)->
      e.preventDefault()
      e.stopPropagation()
      this.trigger('group:show', this.model)###


  class Home.MenuBar extends Marionette.CompositeView
    className: 'ng-scope'
    template: 'header/home/templates/header_container'
    # childView: Home.MenuItem
    # childViewContainer: ".js-left-menu"
    # onChildviewGroupDelete: ->
    #   console.log "ahoy"