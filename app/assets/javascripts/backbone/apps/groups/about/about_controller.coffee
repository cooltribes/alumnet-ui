@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (id)->
      group = AlumNet.request("group:find", id)
      current_user = AlumNet.current_user
      group.on 'find:success', (response, options)->
        layout = AlumNet.request("group:layout", group)
        header = AlumNet.request("group:header", group)
          #todo: implement a function to return the view. like a discovery module
        body = new About.View
          model: group

        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)
        AlumNet.execute('render:groups:submenu')

        body.on 'group:edit:description', (model, newValue) ->
          model.save({description: newValue})

        body.on 'group:edit:group_type', (model, newValue) ->
          model.save({group_type: parseInt(newValue)})
        body.on 'group:edit:join_process', (model, newValue) ->
          model.save({join_process: parseInt(newValue)})

        body.on 'join', () ->
          attrs = { group_id: group.get('id'), user_id: current_user.id }
          request = AlumNet.request('membership:create', attrs)
          request.on 'save:success', (response, options)->
            body.ui.joinDiv.remove()

          request.on 'save:error', (response, options)->
            console.log response.responseJSON

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)