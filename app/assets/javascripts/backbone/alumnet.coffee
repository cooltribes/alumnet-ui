@AlumNet = do (Backbone, Marionette) ->

  App = new Marionette.Application
  App.promises = 0

  App.on 'before:start', (options) ->
    App.api_endpoint = options.api_endpoint
    App.profinda_api_endpoint = options.profinda_api_endpoint
    App.profinda_account_domain = options.profinda_account_domain
    current_user_token = App.request 'user:token'
    App.current_token = current_user_token
    App.environment = options.environment
    App.paymentwall_project_key = options.paymentwall_project_key
    App.paymentwall_secret_key = options.paymentwall_secret_key
    if current_user_token
      $.ajaxSetup
        headers:
          'Authorization': 'Token token="' + current_user_token + '"'
          'Accept': 'application/vnd.alumnet+json;version=1'
      # here get all info of use from api and set in a backbone model
      @current_user = App.request 'get:current_user'#, refresh: true
      @startPusher(options.pusher_key, @current_user)
      App.request 'get:countries'
      App.request 'get:aiesec_countries'

  App.on 'start', ->
    # App.loadReceptiveWidget()
    ## Layer
    App.execute('initialize:layer', App.current_user)
    App.friends = new App.Entities.FriendshipCollection

    if Backbone.history
      Backbone.history.start()
      href = Cookies.get('original_href')
      if App.getCurrentRoute() == ""
        if App.current_user.isExternal()
          App.navigate('#job-exchange', {trigger: true})
        else
          App.navigate(href, {trigger: true})
          # App.navigate('#posts', {trigger: true})

    ## Get profinda api token
    Backbone.ajax
      url: AlumNet.api_endpoint + '/me/profinda_token'
      success: (data)->
        AlumNet.current_user.set('profinda_api_token', data.profinda_api_token)
      error: (response)->
        console.log response.responseJSON
        # message = AlumNet.formatErrorsFromApi(response.responseJSON)
        # $.growl.error(message: message)

  App.addRegions
    headerRegion: "#header-region"
    submenuRegion: "#submenu-region"
    mainRegion:
      selector: "#main-region"
      # regionClass: AnimatedRegion
    tableRegion: "#groups-table"
    chatRegion: "#chat-region"

  App.reqres.setHandler 'default:region', -> App.mainRegion


  App.navigate = (route, options)->
    options || (options = {})
    Backbone.history.navigate(route, options)

  App.getCurrentRoute = ->
    Backbone.history.fragment


  App.reqres.setHandler 'progress', (promise) ->
    App.promises++
    NProgress.start()
    return promise
      .progress ->
        NProgress.inc()
      .always ->
        App.promises--
        NProgress.done() unless App.promises

  Backbone.ajax = ->
    App.request 'progress', Backbone.$.ajax.apply(Backbone.$, arguments)

  App