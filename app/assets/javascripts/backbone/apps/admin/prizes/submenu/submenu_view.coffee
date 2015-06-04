@AlumNet.module 'AdminApp.PrizesSubmenu', (PrizesSubmenu, @AlumNet, Backbone, Marionette, $, _) ->
  class PrizesSubmenu.Menu extends Marionette.ItemView
    template: 'admin/prizes/submenu/templates/submenu'

    initialize: (options) ->
      @prizeTable = options.prizeTable
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
      'click #js-new-prize': 'newPrize'

    newPrize: (e)->
      e.preventDefault()
      modal = new AlumNet.AdminApp.PrizesList.ModalPrize
        model: new AlumNet.Entities.Prize
        prizeTable: @prizeTable
      $('#container-modal').html(modal.render().el)

  API =
    renderSubmenu: (view, tab, table)->
      if view == null
        AlumNet.submenuPrize.empty()
      else
        if view == undefined
          submenu = new PrizesSubmenu.Menu
            tab: tab
            prizeTable: table
        else
          submenu = view
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:admin:prizes:submenu',(view, tab, table) ->
    API.renderSubmenu(view, tab, table)