@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.Controller
    findUsers: ->
      controller.querySearch = ''
      users = AlumNet.request('user:entities', {})
      usersView = new Find.UsersView
        collection: users

      #On fetch, delete current user from the list
      users.on "sync", ()->
        models = this.filter (model)->
          model.get("id") != AlumNet.current_user.id

        this.reset(models)

      AlumNet.mainRegion.show(usersView)
      AlumNet.execute('render:friends:submenu',undefined, 1)
      usersView.on "group:reload", ->
        querySearch = controller.querySearch
        ++usersView.collection.page
        newCollection = AlumNet.request("user:pagination")
        newCollection.url = AlumNet.api_endpoint + '/users?page='+usersView.collection.page+'&per_page='+usersView.collection.rows
        newCollection.fetch
          data: querySearch
          success: (collection)->
            usersView.collection.add(collection.models)

      usersView.on "add:child", (viewInstance)->
        container = $('#friends_list')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
          container.append( $(viewInstance.el) ).masonry 'reloadItems'

      usersView.on 'users:search', (querySearch)->
        controller.querySearch = querySearch
        searchedFriends = AlumNet.request('user:entities', querySearch)
        console.log querySearch
