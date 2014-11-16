@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.Controller
    findUsers: ->
      users = AlumNet.request('user:entities', {})
      usersView = new Find.UsersView
        collection: users

      AlumNet.mainRegion.show(usersView)

      usersView.on 'childview:request', (childView)->
        attrs = { friend_id: childView.model.id }
        friendship = AlumNet.request('current_user:friendship:request', attrs)
        friendship.on 'save:success', (response, options) ->
          childView.removeRequestLink()
        friendship.on 'save:error', (response, options)->
          console.log response.responseJSON

      usersView.on 'childview:accept', (childView)->
        attrs = childView.model.get('friendship')
        friendship = AlumNet.request('current_user:friendship:request', attrs)
        friendship.on 'save:success', (response, options) ->
          childView.removeAcceptLink()
        friendship.on 'save:error', (response, options)->
          console.log response.responseJSON

      usersView.on 'childview:delete', (childView)->
        user = childView.model
        attrs = user.get('friendship')
        friendship = AlumNet.request('current_user:friendship:destroy', attrs)
        friendship.on 'delete:success', (response, options) ->
          users.remove(user)
        friendship.on 'delete:error', (response, options)->
          console.log response.responseJSON


      usersView.on 'users:search', (querySearch)->
        AlumNet.request('user:entities', querySearch)