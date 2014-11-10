@AlumNet.module 'Routers', (Routers, @AlumNet, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter
    before: ->
      user = AlumNet.request 'get:current_user', refresh: true, async: false
      AlumNet.checkRegistrationStatus(user) if user

  # class Routers.Admin extends Marionette.AppRouter
  #   before: ->
  #     App.execute 'header:init:admin'

  # class Routers.SaasAdmin extends Marionette.AppRouter
  #   before: ->
  #     App.execute 'header:init:saas_admin'
