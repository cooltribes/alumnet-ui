@AlumNet.module 'GroupsApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'groups/submenu/templates/submenu'
    className: 'navTopSubBar'

  initialize: (options) ->      
    @tab = options.tab      
    @class = [
        "", "", ""
        "", ""
    ]  
    @class[parseInt(@tab)] = "active" 

  templateHelpers: ->
    model = @model
    classOf: (step) =>
      @class[step]

  API =
    renderSubmenu: (view,tab)->
      if view == null
        AlumNet.submenuRegion.empty()
      else
        if view == undefined
          submenu = new Submenu.Menu
          tab: tab
        else
          submenu = view
        AlumNet.submenuRegion.show(submenu,tab)

  AlumNet.commands.setHandler 'render:groups:submenu',(view,tab) ->
    API.renderSubmenu(view,tab)