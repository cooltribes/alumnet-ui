@AlumNet.module 'UserApp.Friends', (Friends, @AlumNet, Backbone, Marionette, $, _) ->
  class Friends.Controller
    showFriends: ->
      users = AlumNet.request("user:entities", {})
      usersView = new Friends.Users
        # model: group
        collection: users
      AlumNet.mainRegion.show(usersView)

      usersView.on "childview:request", (childView)->
        attrs = { friend_id: childView.model.id }
        friendship = AlumNet.request("friendship:send", attrs)
        friendship.on "save:success", (response, options) ->
          childView.removeLink()
        friendship.on "save:error", (response, options)->
          console.log response.responseJSON

      usersView.on 'users:search', (querySearch)->
        AlumNet.request("user:entities", querySearch)