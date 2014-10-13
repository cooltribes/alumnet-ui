@AlumNet.module "HeaderApp.Show", (Show, @AlumNet, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    initialize: (options) ->
      @show @layout

  class Show.ControllerAuth extends Show.Controller
    initialize: (options) ->
      current_user = App.request 'get:current_user'

      @layout = @getAuthHeaderView current_user

      @listenTo @layout, 'show', =>
        @automatchesCounterRegion()
        @headerSearchRegion()

        @listenTo App.vent, 'profile:refresh', (profile) =>
          current_user.set(profile)

      super options

    getAutomatchesCounterView: (counter) ->
      new Show.AutomatchesCounter
        model: counter

    automatchesCounterRegion: ->
      counter = App.request 'counters:get_help:automatches:entity'

      view = @getAutomatchesCounterView counter

      _.defer =>
        if @layout.automatches_counter_region?
          @show view,
            region: @layout.automatches_counter_region
            loading:
              entities: counter

    getAuthHeaderView: (user) ->
      view = new Show.AuthHeader
        model: user

      @listenTo view, 'notifications:show', ->
        @notificationsRegion()

      view

    getNotificationsView: (notifications) ->
      view = new Show.Notifications
        collection: notifications

      @listenTo view, 'itemview:notification:clicked', (itemView, notification) ->
        App.vent.trigger 'header:notification:clicked', notification

      @listenTo view, 'notifications:hide', ->
        @layout.trigger 'notifications:icon:close'
        @layout.notificationsRegion.close()

      view

    notificationsRegion: ->
      notifications = App.request 'entities:notifications'

      notificationsView = @getNotificationsView notifications

      @show notificationsView,
        region: @layout.notificationsRegion

    headerSearchRegion: ->
      App.vent.trigger 'header:search:init',
        region: @layout.header_search_region

  class Show.ControllerNoAuth extends Show.Controller
    initialize: (options) ->
      current_account = App.request 'get:current_account'

      session = new App.Entities.UserSession
        account_id: current_account.get('id')

      @layout = @getNoAuthHeaderView session

      super options

    getNoAuthHeaderView: (session) ->
      new Show.NoAuthHeader
        model: session

