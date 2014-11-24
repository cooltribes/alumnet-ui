@AlumNet.module 'Routers', (Routers, @AlumNet, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter
    onRoute: (name, path, args) ->
      # user = AlumNet.request 'get:current_user', refresh: true, async: false
      user = AlumNet.request 'get:current_user', async: false
      # AlumNet.checkRegistrationStatus(user) if user
      # console.log user.profile.get("register_step")
      # console.log user.isApproved()
      unless user.isApproved()
        AlumNet.trigger "registration:show"  
        false

      # alert("ye")  

  # class Routers.Admin extends Marionette.AppRouter
  #   before: ->
  #     App.execute 'header:init:admin'

  # class Routers.SaasAdmin extends Marionette.AppRouter
  #   before: ->
  #     App.execute 'header:init:saas_admin'
