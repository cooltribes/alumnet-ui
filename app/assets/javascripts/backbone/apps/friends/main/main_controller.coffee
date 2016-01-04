@AlumNet.module 'FriendsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller

    showMainAlumni: (optionMenu)->
      @layoutAlumni = new Main.FriendsView
      AlumNet.mainRegion.show(@layoutAlumni)
      @showMenuUrl(optionMenu)
      @showSuggestions()
      self = @
      @layoutAlumni.on "navigate:menu", (valueClick)->    
        self.showMenuUrl(valueClick)
      @layoutAlumni.on "navigate:menuRight", (valueClick)->
        switch valueClick
          when "suggestions"
            self.showSuggestions()
          when "filters"
            self.showFilters()

    showFriends: ->
      friendsCollection = AlumNet.request('current_user:friendships:friends')
      friendsCollection.page = 1
      friendsCollection.url = AlumNet.api_endpoint + '/me/friendships/friends'
      friendsCollection.fetch
        data: { page: friendsCollection.page, per_page: friendsCollection.rows }
        reset: true
      friendsView = new AlumNet.FriendsApp.Friends.FriendsView
        collection: friendsCollection

      friendsView.on "friends:reload", ->
        newCollection = AlumNet.request('current_user:friendships:friends')
        newCollection.url = friendsView.collection.url
        @collection.querySearch.page = ++@collection.page
        @collection.querySearch.per_page = @collection.rows
        newCollection.fetch
          data: @collection.querySearch
          success: (collection)->
            friendsView.collection.add(collection.models)
            if collection.length < collection.rows
              friendsView.endPagination()

      friendsView.on "add:child", (viewInstance)->
        container = $('#friends_list')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
          container.append( $(viewInstance.el) ).masonry 'reloadItems'

      @layoutAlumni.users_region.show(friendsView)

    showMyReceived: ->
      friendships = AlumNet.request('current_user:friendships:get', 'received')

      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships

      requestsView.on 'childview:accept', (childView)->
        friendship = childView.model
        friendship.save()
        friendships.remove(friendship)
        #layout.model.decrementCount('pending_received_friendships')
        #layout.model.incrementCount('friends')
        $.growl.notice({ message: "Invitation accepted" })

      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)
        #layout.model.decrementCount('pending_received_friendships')
        $.growl.notice({ message: "Declined invitation" })

      @layoutAlumni.users_region.show(requestsView)

    showMySent: ->
      friendships = AlumNet.request('current_user:friendships:get', 'sent')
      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships

      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)
        #layout.model.decrementCount('pending_sent_friendships')

      @layoutAlumni.users_region.show(requestsView)

    showApproval: ->
      current_user = AlumNet.current_user
      requestsCollection = AlumNet.request('current_user:approval:received')
      approvalView = new AlumNet.FriendsApp.Approval.RequestsView
        collection: requestsCollection

      requestsCollection.on "sync:complete", (collection)->
        approvalCount = requestsCollection.length

      requestsCollection.on "friends:reload", ->
        newCollection = AlumNet.request('current_user:approval:received')
        newCollection.url = requestsCollection.collection.url
        newCollection.fetch
          data: {page: ++@collection.page, per_page: @collection.rows}
          success: (collection)->
            requestsCollection.collection.add(collection.models)
            if collection.length < collection.rows
              requestsCollection.endPagination()
      
      approvalView.on 'childview:accept', (childView)->
        request = childView.model
        request.save {},
          success: ()->
            requestsCollection.remove(request)


      approvalView.on 'childview:decline', (childView)->
        request = childView.model
        request.destroy
          success: ()->

      @layoutAlumni.users_region.show(approvalView)

    findUsers: ->
      controller = @
      controller.querySearch = {}
      users = AlumNet.request('user:entities', {})
      users.page = 1
      usersView = new AlumNet.FriendsApp.Find.UsersView
        collection: users

      #On fetch, delete current user from the list
      users.on "sync", ()->
        models = this.filter (model)->
          model.get("id") != AlumNet.current_user.id

        this.reset(models)

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
          container.append( $(viewInstance.el) ).masonry 'reloadItems'

      usersView.on 'users:search', (querySearch)->
        controller.querySearch = querySearch
        searchedFriends = AlumNet.request('user:entities', querySearch)

      @layoutAlumni.users_region.show(usersView)

    showSuggestions:->
      suggestions = new AlumNet.FriendsApp.Suggestions.FriendsView
      collection = new AlumNet.Entities.SuggestedUsersCollection
      collection.fetch
        #data: {limit: 10}
        success: (collection)->
          array_friends = collection.where(friendship_status: "none")
          collection_friends = new AlumNet.Entities.SuggestedUsersCollection(array_friends)
          suggestions.collection = collection_friends
          suggestions.render()
      @layoutAlumni.filters_region.show(suggestions)

    showFilters:->
      filters = new AlumNet.FriendsApp.Filters.FriendsView
      @layoutAlumni.filters_region.show(filters)

    showMenuUrl: (optionMenu)->
      self = @
      switch optionMenu
        when "myFriends"
          self.showFriends()
        when "friendsApproval"
          self.showApproval()
        when "friendsDiscover"
          self.findUsers()
        when "friendsSent"
          self.showMySent()
        when "friendsReceived"
          self.showMyReceived()


