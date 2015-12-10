@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    showFriends: ->
      current_user = AlumNet.current_user

      friendsLayout = AlumNet.request("users:friends:layout", current_user, 0)

      friendsLayout.on "friends:show:myfriends", (layout)->
        AlumNet.trigger "my:friends:get", layout

      friendsLayout.on "friends:show:received", (layout)->
        AlumNet.trigger "my:friends:received", layout

      friendsLayout.on "friends:show:sent", (layout)->
        AlumNet.trigger "my:friends:sent", layout

      friendsLayout.on "show:approval:requests", (layout)->
        AlumNet.trigger "my:approval:requests", layout

      friendsLayout.on 'friends:search', (querySearch, collection, filter)->
        collection.querySearch = querySearch
        collection.page = 1
        if filter == "sent" or filter == "received"
          querySearch = _.extend querySearch, { filter: filter }
        collection.fetch
          data: querySearch

      #AlumNet.execute('render:friends:submenu',undefined, 0)

      AlumNet.mainRegion.show(friendsLayout)

      AlumNet.trigger "my:friends:get", friendsLayout

    showMyFriends: (layout)->
      friendsCollection = AlumNet.request('current_user:friendships:friends')
      friendsCollection.page = 1
      friendsCollection.url = AlumNet.api_endpoint + '/me/friendships/friends'
      friendsCollection.fetch
        data: { page: friendsCollection.page, per_page: friendsCollection.rows }
        reset: true
      friendsView = new List.FriendsView
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

      layout.body.show(friendsView)

    showSomeonesFriends: (layout, id)->
      friendsCollection = AlumNet.request('user:friendships:friends', id)
      friendsCollection.fetch()
      friendsView = new List.FriendsView
        collection: friendsCollection
      layout.body.show(friendsView)
      friendsView.on 'childview:request', (childView)->
        attrs = { friend_id: childView.model.id }
        friendship = AlumNet.request('current_user:friendship:request', attrs)
        friendship.on 'save:success', (response, options) ->
          AlumNet.current_user.incrementCount('pending_sent_friendships')  #Sent requests count increased
        friendship.on 'save:error', (response, options)->
          console.log response.responseJSON

    showMyMutual: (layout, id)->
      friendsCollection = AlumNet.request('user:friendships:mutual', id)
      friendsCollection.fetch()
      friendsView = new List.FriendsView
        collection: friendsCollection

      layout.body.show(friendsView)
