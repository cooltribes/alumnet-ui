@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  class Users.Controller
    manageUsers: ->

      layoutView = new Users.Layout

      AlumNet.mainRegion.show(layoutView)

      # current_user = AlumNet.current_user
      users = AlumNet.request("user:entities", {})      

      #Bring all the profile fields for each user at the moment of the fetch
      users.on "add", (model) ->        
        model.profile.fetch()


      usersView = new Users.UsersTable
        collection: users

      layoutView.main.show(usersView)

      #Modals view
      modalsView = new Users.Modals
      
      layoutView.modals.show(modalsView)


      # usersView.on 'childview:click:leave', (childView)->
      #   membership = AlumNet.request("membership:destroy", childView.model)
      #   membership.on 'destroy:success', ->
      #     console.log "Destroy Ok"