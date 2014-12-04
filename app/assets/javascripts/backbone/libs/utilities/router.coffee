@AlumNet.module 'Routers', (Routers, @AlumNet, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter
    before: (route)->
      current_user = AlumNet.current_user
      unless current_user.isApproved()
        step = current_user.profile.get('register_step')
        @goToRegistration(step)
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
