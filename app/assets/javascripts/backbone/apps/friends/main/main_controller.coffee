@AlumNet.module 'FriendsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller

    showMainAlumni: (optionMenu)->
      @layoutAlumni = new Main.FriendsView
        model: AlumNet.current_user
        option: optionMenu
      AlumNet.mainRegion.show(@layoutAlumni)
      @showMenuUrl(optionMenu)
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
      AlumNet.navigate("alumni/friends")
      friends = AlumNet.request('current_user:friendships:friends')
      query = { per_page: 12 }

      friendsView = new AlumNet.FriendsApp.Friends.FriendsView
        collection: friends
        parentView: @layoutAlumni
        query: query

      @layoutAlumni.users_region.show(friendsView)

      friends.on "sync", ()->
        models = this.filter (model)->
          model.get("id") != AlumNet.current_user.id
        this.reset(models)

      self = @
      friendsView.on "add:child", (viewInstance)->
        self.applyMasonry


    showMyReceived: ->
      AlumNet.navigate("alumni/received")
      friendships = AlumNet.request('current_user:friendships:get', 'received')
      query = { per_page: 12, filter: "received" }

      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships
        parentView: @layoutAlumni
        query: query
        friendship_type: "received"

      @layoutAlumni.users_region.show(requestsView)

    showMySent: ->
      AlumNet.navigate("alumni/sent")
      friendships = AlumNet.request('current_user:friendships:get', 'sent')
      query = { per_page: 12, filter: "sent" }

      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships
        parentView: @layoutAlumni
        query: query
        friendship_type: "sent"

      @layoutAlumni.users_region.show(requestsView)

    showApproval: ->
      AlumNet.navigate("alumni/approval")
      approvals = AlumNet.request('current_user:approval:received')
      query { per_page: 12 }

      approvalView = new AlumNet.FriendsApp.Approval.RequestsView
        collection: approvals
        parentView: @layoutAlumni
        query: query

      @layoutAlumni.users_region.show(approvalView)

    findUsers: ->
      AlumNet.navigate("alumni/discover")
      users = AlumNet.request("results:users")
      @results = users

      usersView = new AlumNet.FriendsApp.Find.UsersView
        collection: users
        parentView: @layoutAlumni

      @layoutAlumni.users_region.show(usersView)

      users.on "sync", ()->
        models = this.filter (model)->
          model.get("id") != AlumNet.current_user.id
        this.reset(models)

      self = @
      usersView.on "add:child", (viewInstance)->
        self.applyMasonry

    applyMasonry: (viewInstance)->
      container = $('#friends_list')
      container.imagesLoaded ->
        container.masonry
          itemSelector: '.col-md-4'
      container.append( $(viewInstance.el) ).masonry().masonry 'reloadItems'

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
      filters = new AlumNet.Shared.Views.Filters.Profiles.General
        results_collection: @results
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


