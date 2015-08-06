@AlumNet.module 'Routers', (Routers, @AlumNet, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter
    before: (route, args)->
      current_user = AlumNet.current_user
      unless current_user.isApproved()
        ## TODO: for security fetch profile, to be sure that the data is trusted
        step = current_user.profile.get('register_step')
        @goToRegistration(step)
        false
      else
        if current_user.isExternal()
          AlumNet.execute('header:show:external')

          console.log "before"  
          console.log route
          routeChanged = @changeRouteForExternal(route, args)
          console.log route
          if routeChanged
            return false

          if _.contains(@externalRoutes(), route)
            console.log "true"
            true
          else
            AlumNet.trigger 'show:error', 403
            false
        else if current_user.isBanned()
          AlumNet.trigger 'show:banned'
          false
        else
          AlumNet.execute('header:show:regular')
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

    # This method checks the incoming url and change it
    # for the allowed url and then triggers the navigation again,
    # If user is external and the route is in "from" array, basically user will
    # be redirected to correspondant route in "to" array
    # Nelson
    changeRouteForExternal: (route, args)->

      from = [
        "users/:id/posts"
        "users/:id/about"
      ]

      if _.contains(from, route)
        to = [
          "users/#{args[0]}/profile"
          # "users/:id/profile"
        ]
        changes = _.object(from, to)
        route = changes[route]
        AlumNet.navigate("##{route}", {trigger: true})
        return true

      false
    

    externalRoutes: ->
      [
        "job-exchange",
        "job-exchange/my-posts",
        "job-exchange/new",
        "job-exchange/automatches",
        "users/:id/profile",
      ]


  class Routers.Admin extends Marionette.AppRouter
    before: (route)->
      current_user = AlumNet.current_user
      unless current_user.isAdmin()
        return false

      AlumNet.execute('header:show:admin')
      true