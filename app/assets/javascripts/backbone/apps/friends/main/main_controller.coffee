@AlumNet.module 'FriendsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller

    showMainAlumni: (optionMenu)->
      @layoutAlumni = new Main.FriendsView
        model: AlumNet.current_user
        option: optionMenu
      AlumNet.mainRegion.show(@layoutAlumni)
      @showMenuUrl(optionMenu)
      @showSuggestions(optionMenu)
      self = @
      @layoutAlumni.on "navigate:menu", (valueClick)->
        self.showMenuUrl(valueClick)
      @layoutAlumni.on "navigate:menuRight", (valueClick)->
        switch valueClick
          when "suggestions"
            self.showSuggestions()
          when "filters"
            self.showFilters()

      @layoutAlumni.on 'friends:search', (querySearch, collection, filter)->
        if filter == "sent" or filter == "received"
          #
        else
          collection.search(querySearch)
        # collection.querySearch = querySearch
        # collection.page = 1
        # if filter == "sent" or filter == "received"
        #   querySearch = _.extend querySearch, { filter: filter }
        # collection.fetch
        #   data: querySearch

    showFriends: ->
      AlumNet.navigate("alumni/friends")
      friendsCollection = AlumNet.request('current_user:friendships:friends')
      friendsCollection.page = 1
      friendsCollection.url = AlumNet.api_endpoint + '/me/friendships/friends'
      friendsCollection.fetch
        data: { page: friendsCollection.page, per_page: friendsCollection.rows }
        reset: true

      # uncomment this for elastic search

      # friendsCollection = new AlumNet.Entities.SearchResultCollection null,
      #   type: 'profile'
      # friendsCollection.model = AlumNet.Entities.User
      # friendsCollection.url = AlumNet.api_endpoint + '/users'
      # friendsCollection.search()

      #On fetch, delete current user from the list
      friendsCollection.on "sync", ()->
        models = this.filter (model)->
          model.get("id") != AlumNet.current_user.id

        this.reset(models)

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
          container.append( $(viewInstance.el) ).masonry().masonry 'reloadItems'

      @layoutAlumni.users_region.show(friendsView)

    showMyReceived: ->
      AlumNet.navigate("alumni/received")
      friendships = AlumNet.request('current_user:friendships:get', 'received')

      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships

      self = @
      requestsView.on 'childview:accept', (childView)->
        friendship = childView.model
        friendship.save()
        friendships.remove(friendship)
        self.layoutAlumni.model.decrementCount('pending_received_friendships')
        self.layoutAlumni.model.incrementCount('friends')
        $.growl.notice({ message: "Invitation accepted" })

      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)
        self.layoutAlumni.model.decrementCount('pending_received_friendships')
        $.growl.notice({ message: "Declined invitation" })

      @layoutAlumni.users_region.show(requestsView)

    showMySent: ->
      AlumNet.navigate("alumni/sent")
      friendships = AlumNet.request('current_user:friendships:get', 'sent')
      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships

      self = @
      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)
        self.layoutAlumni.model.decrementCount('pending_sent_friendships')

      @layoutAlumni.users_region.show(requestsView)

    showApproval: ->
      AlumNet.navigate("alumni/approval")
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
            AlumNet.current_user.decrementCount('pending_approval_requests')

      approvalView.on 'childview:decline', (childView)->
        request = childView.model
        request.destroy
          success: ()->
            AlumNet.current_user.decrementCount('pending_approval_requests')
      @layoutAlumni.users_region.show(approvalView)

    findUsers: ->
      AlumNet.navigate("alumni/discover")
      controller = @
      controller.querySearch = {}

      controller.users = new AlumNet.Entities.SearchResultCollection null,
        type: 'profile'
      controller.users.model = AlumNet.Entities.User
      controller.users.url = AlumNet.api_endpoint + '/users'
      controller.users.search()

      usersView = new AlumNet.FriendsApp.Find.UsersView
        collection: controller.users

      #On fetch, delete current user from the list
      controller.users.on "sync", ()->
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
          container.append( $(viewInstance.el) ).masonry().masonry 'reloadItems'

      usersView.on 'users:search', (querySearch)->
        controller.querySearch = querySearch

      @layoutAlumni.users_region.show(usersView)

    showSuggestions:(optionMenu)->
      collection = new AlumNet.Entities.SuggestedUsersCollection
      collection.fetch
        data: { limit: 10 }

      model = new Backbone.Model
      if optionMenu != "friendsDiscover"
        model.set "showDiscover", true
      else
        model.set "showDiscover", false

      suggestions = new AlumNet.FriendsApp.Suggestions.FriendsView
        collection: collection
        model: model

      @layoutAlumni.filters_region.show(suggestions)

    showFilters: ()->
      controller = @
      filters = new AlumNet.Shared.Views.Filters.Profiles.General
        results_collection: controller.users
      #filters = new AlumNet.FriendsApp.Filters.FriendsView
      @layoutAlumni.filters_region.show(filters)

    showMenuUrl: (optionMenu)->
      self = @
      switch optionMenu
        when "myFriends"
          AlumNet.setTitle('My Friends')
          self.showFriends()
        when "friendsApproval"
          AlumNet.setTitle('Approval Requests')
          self.showApproval()
        when "friendsDiscover"
          AlumNet.setTitle('Discover Alumni')
          self.findUsers()
        when "friendsSent"
          AlumNet.setTitle('Friendships Sent')
          self.showMySent()
        when "friendsReceived"
          AlumNet.setTitle('Friendships Received')
          self.showMyReceived()
      @showSuggestions(optionMenu)


