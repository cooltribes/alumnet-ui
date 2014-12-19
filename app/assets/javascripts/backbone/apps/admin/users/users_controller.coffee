@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  class Users.Controller
    manageUsers: ->

      AlumNet.execute('render:admin:submenu')

      layoutView = new Users.Layout

      AlumNet.mainRegion.show(layoutView)

      # current_user = AlumNet.current_user
      users = AlumNet.request("admin:user:entities", {})      

      usersView = new Users.UsersTable
        collection: users
        modals: layoutView.modals
                
      layoutView.main.show(usersView)


      searchCollection = new AlumNet.Entities.Search [
        first: true

      ]
      filtersView = new Users.Filters        
        collection: searchCollection
                
      layoutView.filters.show(filtersView)




      #Bring all the profile fields for each user at the moment of the fetch
      # users.on "add", (model) ->        
      #   # model.profile.fetch()
      #   model.profile.fetch
      #     async: false    

      # users.on "sync", () ->                
      #   usersView = new Users.UsersTable
      #     collection: users
      #     modals: layoutView.modals
                  
      #   layoutView.main.show(usersView)
      