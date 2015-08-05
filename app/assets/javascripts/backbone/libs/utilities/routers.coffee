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
          route = @changeRouteForExternal(route)
          console.log route
          
          
          if _.contains(@externalRoutes(), route)
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

    changeRouteForExternal: (route)->
      from = [
        "users/:id/posts"
      ]

      if _.contains(from, route)
        to = [
          "users/:id/profile"
        ]
        changes = _.object(from, to)
        route = changes[route]
        # AlumNet.navigate("##{route}")

      route

    onRoute: (name, path, args)->
      console.log "onroute"  
      console.log name
      console.log path
      console.log args


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