@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.Controller
    findUsers: ->
      users = AlumNet.request("user:entities", {})
      usersView = new Find.UsersView
        collection: users

      AlumNet.mainRegion.show(usersView)

      usersView.on "childview:request", (childView)->
        attrs = { friend_id: childView.model.id }
        friendship = AlumNet.request("friendship:request", attrs)
        friendship.on "save:success", (response, options) ->
          childView.removeLink()
        friendship.on "save:error", (response, options)->
          console.log response.responseJSON

      usersView.on 'users:search', (querySearch)->
        AlumNet.request("user:entities", querySearch)