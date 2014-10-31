@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.MenuItem extends Backbone.Model    

  class Entities.MenuItemCollection extends Backbone.Collection
    
    model: Entities.MenuItem

  initializeMenu = ->
    Entities.items = new Entities.MenuItemCollection [
      {caption: "Alumni", "iconClass": "icon-entypo-user"},
      {caption: "Groups", "iconClass": "icon-entypo-share"},
      {caption: "Events", "iconClass": "ico-calendar"},
      {caption: "Programs", "iconClass": "ico-give-help"},
    ]

  API =
    getMenuItems: ->
      initializeMenu() if Entities.items == undefined
      
      Entities.items

  AlumNet.reqres.setHandler 'menu:items', ->
    API.getMenuItems()
