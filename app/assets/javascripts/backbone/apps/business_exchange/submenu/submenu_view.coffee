@AlumNet.module 'BusinessExchangeApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'business_exchange/submenu/templates/submenu'
    className: 'navTopSubBar'

    initialize: (options) ->
      view = @
      @invitations = new AlumNet.Entities.TaskInvitationCollection
      @automatches = new AlumNet.Entities.BusinessExchangeCollection

      @automatches.fetch
        url: AlumNet.api_endpoint + '/business_exchanges/automatches'
        success: (collection_automatches) ->
          
          lengthAutomatches = collection_automatches.length
          view.updateAutomatches(lengthAutomatches)

      @invitations.fetch
        success: (collection_invites)->
          lengthIvites = collection_invites.length
          view.updateInvite(lengthIvites)

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

    ui:
      'linkInvites': '#invites'
      'numberInvites': '#js-invites'
      'linkAutomatches': '#automatches'
      'numberAutomatches': '#js-automatches'

    updateInvite: (length)->
      if length == 0
        @ui.linkInvites.hide()
      else
        @ui.numberInvites.html(length)
        @ui.linkInvites.show()

    updateAutomatches: (len)->
      if len == 0
        @ui.linkAutomatches.hide()
      else
        @ui.numberAutomatches.html(len)
        @ui.linkAutomatches.show()  

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
