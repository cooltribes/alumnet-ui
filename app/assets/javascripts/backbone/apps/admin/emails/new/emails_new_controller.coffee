@AlumNet.module 'AdminApp.EmailsNew', (EmailsNew, @AlumNet, Backbone, Marionette, $, _) ->
  class EmailsNew.Controller
    emailsNew: ->
      layout = new EmailsNew.Layout
      groups = AlumNet.request('group:entities:admin', {})
      groups.on 'fetch:success': ->
        groups_users =  new EmailsNew.GroupsUsers
          groups: groups
          collection: new Backbone.Collection

        AlumNet.mainRegion.show(layout)
        layout.groups_users.show(groups_users)

      AlumNet.execute('render:admin:emails:submenu', undefined, 0)