@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  class Users.Controller
    usersList: (id)->
      AlumNet.execute('render:admin:users:submenu', undefined, 0)

      # Main container
      layoutView = new Users.Layout

      AlumNet.mainRegion.show(layoutView)

      # current_user = AlumNet.current_user
      if id?
        querySearch =
          q:
            "id_eq": id
        users = AlumNet.request("admin:user:entities", querySearch)
      else
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
        q = {}

        @collection.each (model)->
          if model.isValid(true)

            field = model.get("field")
            operator = model.get("operator")
            comparator = model.get("comparator")
            value = model.get("value")
            attr = "#{field}_#{comparator}"

            if comparator in ["cont_any","in",'not_in','not_eq','gt','lt','lteq','gteq','eq']
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