@AlumNet.module 'LayerLogin', (Headers, @AlumNet, Backbone, Marionette, $, _) ->
  #here the code for login

  class Login
    init: (user)->
      self = @
      console.log 'Init Layer'

      AlumNet.layerClient = new layer.Client
        appId: 'layer:///apps/staging/13c942e8-2d88-11e6-8279-a6424d091611'

      AlumNet.layerClient.on 'challenge', (e)->
        callback = (token)->
          e.callback(token)
        self.getIdentityToken(e.nonce, callback)

      AlumNet.layerClient.on 'ready', (e)->
        console.log "Initialize Chat"
        # chatLayout = new AlumNet.ChatApp.Chat.Layout
        # AlumNet.chatRegion.show(chatLayout)

    getIdentityToken: (nonce, callback)->
      Backbone.ajax
        url: AlumNet.api_endpoint + '/me/identity_layer'
        method: 'POST'
        data: { nonce: nonce }
        success: (token)->
          callback(token)

  AlumNet.commands.setHandler 'initialize:layer', (user)->
    login = new Login
    login.init(user)
