@AlumNet.module 'AdminApp.Dashboard.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class UserStats.Controller extends AlumNet.Controllers.Base    

    initialize: (options) ->
      @layout = @getLayoutView()

      # @listenTo @layout, 'show', =>
      #   @showProperRegions()

      @show @layout

    getLayoutView: ->
      view = new Users.Layout

      @listenTo view, 'tab_selected', (tab_name) ->
        @showTab tab_name

      view  
