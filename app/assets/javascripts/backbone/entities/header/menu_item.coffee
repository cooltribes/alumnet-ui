@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.MenuItem extends Backbone.Model    

  class Entities.MenuItemCollection extends Backbone.Collection
    
    model: Entities.MenuItem

  initializeMenu = ->
    Entities.items = new Entities.MenuItemCollection [
      {caption: "Groups", "iconClass": "groups-link"},
      {caption: "Events", "iconClass": "events-link"},
      {caption: "Programs", "iconClass": "programs-link"},
    ]

  API =
    getMenuItems: ->
      initializeMenu() if Entities.items == undefined
      
      Entities.items

  AlumNet.reqres.setHandler 'menu:items', ->
    API.getMenuItems()
