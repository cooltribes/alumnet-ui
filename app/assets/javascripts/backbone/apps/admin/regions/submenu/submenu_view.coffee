@AlumNet.module 'AdminApp.RegionsSubmenu', (RegionsSubmenu, @AlumNet, Backbone, Marionette, $, _) ->
  class RegionsSubmenu.Menu extends Marionette.ItemView
    template: 'admin/regions/submenu/templates/submenu'

    initialize: (options) ->
      @regionTable = options.regionTable
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

    events:
      'click #js-new-region': 'newRegion'

    newRegion: (e)->
      e.preventDefault()
      modal = new AlumNet.AdminApp.Regions.ModalRegion
        model: new AlumNet.Entities.Region
        regionTable: @regionTable
      $('#container-modal').html(modal.render().el)

  API =
    renderSubmenu: (view, tab, table)->
      if view == null
        AlumNet.submenuRegion.empty()
      else
        if view == undefined
          submenu = new RegionsSubmenu.Menu
            tab: tab
            regionTable: table
        else
          submenu = view
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:admin:regions:submenu',(view, tab, table) ->
    API.renderSubmenu(view, tab, table)