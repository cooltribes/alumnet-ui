@AlumNet.module 'FriendsApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'friends/submenu/templates/submenu'
    className: 'navTopSubBar'

    ui:
      'linkMenu':'#js-discover, #js-friend'
      
    initialize: (options) ->
      view = @
      current_user = AlumNet.current_user
      approval = AlumNet.request('current_user:approval:received')
      approval.on "sync:complete", (collection_approval)->
        lengthApproval = collection_approval.length
        view.updateApproval(lengthApproval)

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
      'numberApproval': '#js-approval'

    updateApproval:(length) ->
       @ui.numberApproval.html(length)
       
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

  AlumNet.commands.setHandler 'render:friends:submenu',(view,tab) ->
    API.renderSubmenu(view,tab)
