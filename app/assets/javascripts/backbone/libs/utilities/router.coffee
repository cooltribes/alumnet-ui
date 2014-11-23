@AlumNet.module 'Routers', (Routers, @AlumNet, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter
    onRoute: ->
      # user = AlumNet.request 'get:current_user', refresh: true, async: false
      user = AlumNet.request 'get:current_user', async: false
      # AlumNet.checkRegistrationStatus(user) if user

      unless user.isActive()
        AlumNet.trigger "registration:show"      
        false

      # alert("ye")  

  # class Routers.Admin extends Marionette.AppRouter
  #   before: ->
  #     App.execute 'header:init:admin'

  # class Routers.SaasAdmin extends Marionette.AppRouter
  #   before: ->
  #     App.execute 'header:init:saas_admin'
