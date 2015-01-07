@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  class Users.Controller
    manageUsers: ->
      AlumNet.execute('render:admin:submenu')

      # Main container
      layoutView = new Users.Layout

      AlumNet.mainRegion.show(layoutView)

      # current_user = AlumNet.current_user
      users = AlumNet.request("admin:user:entities", {})      


      # Region with users list
      usersView = new Users.UsersTable
        collection: users
        modals: layoutView.modals
                
      layoutView.main.show(usersView)


      searchCollection = new AlumNet.Entities.Search [
        first: true
      ]

      # Region with filters
      filtersView = new Users.Filters        
        collection: searchCollection
                
      layoutView.filters.show(filtersView)

      # When search button is clicked
      filtersView.on 'filters:search', ->     

        validCollection = true

        @collection.each (model)->
          if !model.isValid(true)                       
            validCollection = false

        #Only if all filters are valid
        if validCollection
          model = @collection.at 0
          
          #The main search query   
          querySearch = {}  
          field = model.get("field")
          operator = model.get("operator")
          value = model.get("value")
          
          if field == "name"     
            querySearch =
              q: 
                m: operator
                profile_first_name_cont: value
                profile_last_name_cont: value
              # q : [
              #   {
              #     m: "or"
              #     a: "profile_first_name"
              #     p: "cont"
              #     v: "h"
              #   },
              #   {
              #     m: "or"
              #     a: "profile_last_name"
              #     p: "cont"
              #     v: "h"
              #   },
              # ]  
                # m: operator
                # profile_first_name_cont: value
                # profile_last_name_cont: value              
          
          AlumNet.request("admin:user:entities", querySearch)


    

      
