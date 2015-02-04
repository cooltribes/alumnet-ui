@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  class Users.Controller
    manageUsers: ->
      AlumNet.execute('render:admin:submenu')

      # Main container
      layoutView = new Users.Layout

      AlumNet.mainRegion.show(layoutView)

      # current_user = AlumNet.current_user
      users = AlumNet.request("admin:user:entities", {})      
      window.users = users

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
        q = {}

        @collection.each (model)->
          if model.isValid(true)    

            field = model.get("field")
            operator = model.get("operator")
            comparator = model.get("comparator")
            value = model.get("value")
            attr = "#{field}_#{comparator}"

            if comparator in ["cont_any", "in"]
              if q[attr]?
                q[attr].push value
              else
                q[attr] = [value]
            

          else
            validCollection = false
            

        #Only if all filters are valid
        if validCollection          
          #Matching ?
          q.m = @ui.logicOp.val()
          q["profile_first_name_or_cont"]

          querySearch = 
            q: q
            
          AlumNet.request("admin:user:entities", querySearch)

        #   @collection.each model, ->



        #   model = @collection.at 0
          
        #   #The main search query   
        #   querySearch = {}  
          
          
        #   if field == "name"     
        #     querySearch =
        #       # q: [ 
        #       #   s: [
        #       #     {
        #       #       name: ""
        #       #       dir: "asc"
        #       #     }
        #       #   ]               
        #       #   g: [
        #       #     {
        #       #       c: [
        #       #         { 
        #       #           a: [
        #       #             {
        #       #               name: "profile_first_name"
        #       #             }
        #       #           ]
        #       #           p: "cont"
        #       #           v: [
        #       #             {
        #       #               value: "go"
        #       #             }
        #       #           ]
                        
        #       #         }
        #       #       ]
        #       #       m: "and"  
        #       #     }                    
        #       #   ]
        #       # ]
                  
        #       q :
        #         m: operator
        #         profile_first_name_cont: value
        #         profile_last_name_cont: value              
          


    

      
