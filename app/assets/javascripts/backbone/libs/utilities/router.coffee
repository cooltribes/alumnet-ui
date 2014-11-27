@AlumNet.module 'Routers', (Routers, @AlumNet, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter
    before: (route)->
      user = AlumNet.request 'get:current_user', async: false
      unless user.isApproved()
        AlumNet.trigger "registration:show"
        false