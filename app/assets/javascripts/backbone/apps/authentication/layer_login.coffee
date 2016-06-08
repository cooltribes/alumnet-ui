@AlumNet.module 'LayerLogin', (Headers, @AlumNet, Backbone, Marionette, $, _) ->
  #here the code for login

  class Login
    init: (user)->
      self = @
      console.log 'Init Layer'

      AlumNet.layerClient = new layer.Client
        appId: 'layer:///apps/staging/b92b9c98-27fe-11e6-a7ff-8c34b9167c29'

      AlumNet.layerClient.on 'challenge', (e)->
        callback = (token)->
          e.callback(token)
        self.getIdentityToken(e.nonce, callback)

      AlumNet.layerClient.on 'ready', (e)->
        console.log "Initialize Chat"

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
