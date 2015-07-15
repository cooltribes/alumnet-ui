@AlumNet.module 'Controllers', (Controllers, App, Backbone, Marionette, $, _) ->

  # class Controllers.Base extends Marionette.Controller
  class Controllers.Base

    constructor: (options = {}) ->
      @region = options.region or App.request 'default:region'
      # @_instance_id = _.uniqueId 'controller'
      # App.execute 'register:instance', @, @_instance_id
      # super options

    close: ->
      # App.execute 'unregister:instance', @, @_instance_id
      super

    show: (view, options = {}) ->
      _.defaults options,
        loading: false
        region: @region

      # allow us to pass in a controller instance instead of a view
      # if controller instance, set view to the mainView of the controller
      view = if view.getMainView then view.getMainView() else view
      throw new Error("getMainView() did not return a view instance or #{view?.constructor?.name} is not a view instance") if not view

      @setMainView view
      @_manageView view, options

    getMainView: ->
      @_mainView

    setMainView: (view) ->
      ## the first view we show is always going to become the mainView of our
      ## controller (whether its a layout or another view type).  So if this
      ## *is* a layout, when we show other regions inside of that layout, we
      ## check for the existance of a mainView first, so our controller is only
      ## closed down when the original mainView is closed.

      return if @_mainView
      @_mainView = view
      @listenTo view, 'close', @close

    _manageView: (view, options) ->
      if options.loading
        App.execute 'show:loading', view, options
      else
        options.region.show view

    mergeDefaultsInto: (obj) ->
      obj = if _.isObject(obj) then obj else {}
      _.defaults obj, @_getDefaults()

    _getDefaults: ->
      _.clone _.result(@, 'defaults')

    feature_enabled: (feature_name) ->
      if @__features(feature_name)?
        @__features(feature_name)
      else
        true

    __features: (feature_name)->
      App.features ||= App.request('features:entities')
      App.features.getContent(feature_name)

    label_for: window.label_for
    __labels: window.__labels


  class Controllers.NotAuthenticated extends App.Controllers.Base
    constructor: (options = {}) ->
      if App.current_user
        App.navigate(App.rootRoute)
        App.vent.trigger 'default:authenticated:init'
      else
        super options

  class Controllers.Authenticated extends App.Controllers.Base
    constructor: (options = {}) ->
      if App.current_user
        super options
      else
        App.navigate(App.rootRoute)
        App.vent.trigger 'default:notauthenticated:init'
