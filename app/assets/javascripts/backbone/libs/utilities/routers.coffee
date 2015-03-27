@AlumNet.module 'Routers', (Routers, @AlumNet, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter
    before: (route)->
      current_user = AlumNet.current_user
      unless current_user.isApproved()
        ## TODO: for security fetch profile, to be sure that the data is trusted
        step = current_user.profile.get('register_step')
        @goToRegistration(step)
        false
      else
        if current_user.isBanned()
          AlumNet.trigger 'show:banned'
          false
        else
          true

    goToRegistration: (step)->

      switch step
        when 'initial'
          AlumNet.trigger 'registration:profile'
        when 'profile'
          AlumNet.trigger 'registration:contact'
        when 'contact', 'experience_a', 'experience_b', 'experience_c'
          AlumNet.trigger 'registration:experience', step
        when 'experience_d'
          AlumNet.trigger 'registration:skills'
        when 'skills'
          AlumNet.trigger 'registration:approval'
        else
          false

  class Routers.Admin extends Marionette.AppRouter
    before: (route)->
      current_user = AlumNet.current_user
      unless current_user.isAlumnetAdmin()
        return false

      true