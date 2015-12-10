@AlumNet.module 'GroupsApp.Invite', (Invite, @AlumNet, Backbone, Marionette, $, _) ->
  class Invite.Controller
    listUsers: (id)->
      controller = @
      controller.querySearch = {}
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        if group.userCanInvite()
          users = AlumNet.request("user:entities", {})
          usersView = new Invite.Users
            model: group
            collection: users
          AlumNet.mainRegion.show(usersView)
          #AlumNet.execute('render:groups:submenu')
          usersView.on "user:reload", ->
            querySearch = controller.querySearch
            ++usersView.collection.page
            newCollection = AlumNet.request("user:pagination")
            newCollection.url = AlumNet.api_endpoint + '/users'
            query = _.extend(querySearch, { page: usersView.collection.page, per_page: usersView.collection.rows })
            newCollection.fetch
              data: query
              success: (collection)->
                usersView.collection.add(collection.models)

          usersView.on "add:child", (viewInstance)->
            container = $('#friends_list')
            container.imagesLoaded ->
              container.masonry
                itemSelector: '.col-md-4'
              container.append( $(viewInstance.el) ).masonry 'reloadItems'

          #When invite link is clicked
          usersView.on 'childview:invite', (childView) ->
            attrs = { user_id: childView.model.get('id'), group_id: group.get('id')}
            request = AlumNet.request('membership:create', attrs)
            request.on 'save:success', (response, options)->
              childView.removeLink()
            request.on 'save:error', (response, options)->
              console.log response.responseJSON

          #When search button is clicked
          usersView.on 'users:search', (querySearch)->
            controller.querySearch = querySearch
            AlumNet.request("user:entities", querySearch)
        else
          AlumNet.trigger('show:error', 403)

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)