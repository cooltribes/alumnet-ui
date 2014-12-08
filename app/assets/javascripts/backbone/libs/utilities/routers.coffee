@AlumNet.module 'Routers', (Routers, @AlumNet, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter
    before: (route)->
      currrent_user = AlumNet.current_user
      unless currrent_user.isApproved()
        #using current_user the logic of the redirects should be here.
        AlumNet.trigger "registration:show"
        false
      else
        true

  class Routers.Admin extends Marionette.AppRouter
    # before: (route)->
    #   currrent_user = AlumNet.current_user
    #   unless currrent_user.isApproved()
    #     #using current_user the logic of the redirects should be here.
    #     AlumNet.trigger "registration:show"
    #     false
    #   else
    #     true
