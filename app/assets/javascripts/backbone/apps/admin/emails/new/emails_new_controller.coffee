@AlumNet.module 'AdminApp.EmailsNew', (EmailsNew, @AlumNet, Backbone, Marionette, $, _) ->
  class EmailsNew.Controller
    emailsNew: ->
      layout = new EmailsNew.Layout
      current_user = AlumNet.current_user
      groups = AlumNet.request('group:entities:admin', {})
      groups.on 'fetch:success': ->
        groups_users =  new EmailsNew.GroupsUsers
          groups: groups
          collection: new Backbone.Collection
          current_user: current_user

        AlumNet.mainRegion.show(layout)
        layout.groups_users.show(groups_users)

        groups_users.on 'group:edit:api_key', (model, newValue) ->
          model.save({api_key: newValue})

        groups_users.on 'group:edit:list_id', (model, newValue) ->
          model.save({list_id: newValue})

      AlumNet.execute('render:admin:emails:submenu', undefined, 0)