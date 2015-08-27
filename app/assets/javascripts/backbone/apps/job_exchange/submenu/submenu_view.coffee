@AlumNet.module 'ProgramsApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'job_exchange/submenu/templates/submenu'
    className: 'navTopSubBar'

    initialize: (options) ->
      view = @
      invitations = new AlumNet.Entities.TaskInvitationCollection
      invitations.fetch
        success: (collection_invitations)->
          lengthInvitations = collection_invitations.length
          view.updateInvitations(lengthInvitations)

      automatches = new AlumNet.Entities.JobExchangeCollection
      automatches.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/automatches'
        success: (collection_automatches)->
          lengthAutomatches = collection_automatches.length
          view.updateAutomatches(lengthAutomatches)

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
      optionIsVisible: ()->
        !AlumNet.current_user.isExternal()

    ui:
      'linkInvitations': '#invitations'
      'numberInvitations': '#js-invitations'
      'linkAutomatches': '#automatches'
      'numberAutomatches': '#js-automatches'

    updateAutomatches:(length) ->
      if length == 0
        @ui.linkAutomatches.hide()
      else
        @ui.numberAutomatches.html(length)
        @ui.linkAutomatches.show()  

    updateInvitations:(length) ->
      if length == 0
        @ui.linkInvitations.hide()
      else
        @ui.numberInvitations.html(length)
        @ui.linkInvitations.show()

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

  AlumNet.commands.setHandler 'render:job_exchange:submenu',(view,tab) ->
    API.renderSubmenu(view,tab)
