@AlumNet.module 'PointsApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'points/submenu/templates/submenu'
    className: 'navTopSubBar'

    initialize: (options) ->
      console.log options
      @tab = options.tab
      @pointsBar = options.pointsBar   
      @class = [
        "", "", ""
        "", ""
      ]  
      @class[parseInt(@tab)] = "active"

    templateHelpers: ->
      model = @model
      pointsBar : @pointsBar
      classOf: (step) =>
        @class[step]
      prizes : 2
      chosenPrizes: (prizes) =>
        if(prizes>0)
          return "pointsBar--active"
        else
          return ""
      points: AlumNet.current_user.profile.get('points')

  API =
    renderSubmenu: (view,tab,pointsBar)->
      if view == null
        AlumNet.submenuRegion.empty()
      else
        if view == undefined
          submenu = new Submenu.Menu
            tab: tab
            pointsBar: pointsBar
        else
          submenu = view
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:points:submenu',(view,tab,pointsBar) ->
    API.renderSubmenu(view,tab,pointsBar)
