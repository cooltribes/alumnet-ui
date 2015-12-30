@AlumNet.module 'FriendsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.FriendsView extends Marionette.LayoutView
    template: 'friends/main/templates/layout'
    
    regions:
      users_region: '#users-region'
      filters_region: '#filters-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .optionMenuRight' : 'goOptionMenuRight'

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @trigger "navigate:menu",valueClick

    goOptionMenuRight: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @trigger "navigate:menuRight",valueClick
