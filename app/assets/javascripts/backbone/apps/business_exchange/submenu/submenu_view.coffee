@AlumNet.module 'BusinessExchangeApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'business_exchange/submenu/templates/submenu'
    className: 'navTopSubBar'

    initialize: (options) ->
      @invitations = new AlumNet.Entities.TaskInvitationCollection
      @invitations.fetch()
      @tab = options.tab
      @class = [
        "", "", ""
        "", ""
      ]
      @class[parseInt(@tab)] = "active"

    templateHelpers: ->
      console.log @invitations.length
      length: @invitations.length
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
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:business_exchange:submenu',(view,tab) ->
    API.renderSubmenu(view,tab)
