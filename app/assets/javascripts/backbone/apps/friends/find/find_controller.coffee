@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.Controller
    findUsers: ->
      controller = @
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
      usersView.on "user:reload", ->
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

      usersView.on 'childview:request', (childView)->
        attrs = { friend_id: childView.model.id }
        friendship = AlumNet.request('current_user:friendship:request', attrs)
        friendship.on 'save:success', (response, options) ->
          AlumNet.current_user.incrementCount('pending_sent_friendships')#Sent requests count increased          
        friendship.on 'save:error', (response, options)->
          console.log response.responseJSON

      usersView.on 'childview:accept', (childView)->
        attrs = childView.model.get('friendship')
        friendship = AlumNet.request('current_user:friendship:request', attrs)
        friendship.on 'save:success', (response, options) ->
          AlumNet.current_user.decrementCount('pending_received_friendships') #Recieved requests count decreased
          AlumNet.current_user.incrementCount('friends') #Friend counter increased
          usersView.render()
          friendship.on 'save:error', (response, options)->
          console.log response.responseJSON

      usersView.on 'users:search', (querySearch)->
        controller.querySearch = querySearch
        searchedFriends = AlumNet.request('user:entities', querySearch)
        console.log querySearch
        