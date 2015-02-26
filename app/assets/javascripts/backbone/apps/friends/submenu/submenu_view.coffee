@AlumNet.module 'FriendsApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'friends/submenu/templates/submenu'
    className: 'navTopSubBar'

    ui:
      'linkMenu':'#js-discover, #js-friend'


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

    clickLink: (e) ->
      #$(e.currentTarget).parent().addClass("active")
      #$(e.currentTarget).parent().parent().siblings().children().removeClass("active")
      e.preventDefault()
      e.stopPropagation()
      id = $(e.currentTarget).attr('id').substring(3)

      @toggleLink(id)

    toggleLink: (id)->
      link = $("#js-#{id}")
      this.$("[id^=js-]").parent().removeClass("active")
      link.parent().addClass("active")

  API =
    renderSubmenu: (view,tab)->
      console.log tab
      console.log "Hola"
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
        AlumNet.submenuRegion.show(submenu,tab)

  AlumNet.commands.setHandler 'render:friends:submenu',(view,tab) ->
    API.renderSubmenu(view,tab)
