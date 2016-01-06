@AlumNet.module 'GroupsApp.Settings', (Settings, @AlumNet, Backbone, Marionette, $, _) ->
  class Settings.Controller
    showSettings: (id)->
      group = AlumNet.request("group:find", id)
      current_user = AlumNet.current_user
      group.on 'find:success', (response, options)->
        layout = AlumNet.request("group:layout", group,7)
        header = AlumNet.request("group:header", group)

        body = new Settings.SettingsLayout
          model: group
          current_user: current_user

        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)
        AlumNet.execute('render:groups:submenu')

        body.on 'group:edit:group_type', (model, newValue) ->
          model.save({group_type: parseInt(newValue)})
        body.on 'group:edit:join_process', (model, newValue) ->
          model.save({join_process: parseInt(newValue)})
        body.on 'group:edit:official', (model, newValue) ->
          model.save({official: parseInt(newValue)})
          
        body.on 'group:edit:mailchimp', (model, newValue) ->
          model.save({mailchimp: parseInt(newValue)})
        body.on 'group:edit:api_key', (model, newValue) ->
          model.save({api_key: newValue})
        body.on 'group:edit:list_id', (model, newValue) ->
          model.save({list_id: newValue})

        body.on 'join', () ->
          attrs = { group_id: group.get('id'), user_id: current_user.id }
          request = AlumNet.request('membership:create', attrs)
          request.on 'save:success', (response, options)->
            body.ui.joinDiv.remove()

          request.on 'save:error', (response, options)->
            console.log response.responseJSON

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)



