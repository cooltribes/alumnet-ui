@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.Controller
    findUsers: ->
      controller = @
      controller.querySearch = {}
      users = AlumNet.request('user:entities', {})
      users.page = 1
      usersView = new Find.UsersView
        collection: users

      #On fetch, delete current user from the list
      users.on "sync", ()->
        models = this.filter (model)->
          model.get("id") != AlumNet.current_user.id

        this.reset(models)

      AlumNet.mainRegion.show(usersView)
      #AlumNet.execute('render:friends:submenu',undefined, 1)

      usersView.on "user:reload", ->
        querySearch = controller.querySearch
        newCollection = AlumNet.request("user:pagination")
        newCollection.url = AlumNet.api_endpoint + '/users'
        query = _.extend(querySearch, { page: ++@collection.page, per_page: @collection.rows })
        newCollection.fetch
          data: query
          success: (collection)->
            usersView.collection.add(collection.models)
            if collection.length < collection.rows
              usersView.endPagination()

      usersView.on "add:child", (viewInstance)->
        container = $('#friends_list')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
          container.append( $(viewInstance.el) ).masonry().masonry 'reloadItems'

      usersView.on 'users:search', (querySearch)->
        controller.querySearch = querySearch
        searchedFriends = AlumNet.request('user:entities', querySearch)


