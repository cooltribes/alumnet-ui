@AlumNet.module 'AdminApp.EmailsNew', (EmailsNew, @AlumNet, Backbone, Marionette, $, _) ->
  class EmailsNew.Controller
    emailsNew: ->

      collection = new Backbone.Collection [
        name: "Diana"
        ,
        name: "Nelson"
      ]

      layout = new EmailsNew.Layout
      groups_users =  new EmailsNew.GroupsUsers
        collection: collection

      users =  new EmailsNew.Users
        collection: collection


      create_email = new EmailsNew.CreateEmail


      AlumNet.mainRegion.show(layout)
      layout.groups_users.show(groups_users)
      layout.users.show(users)
      layout.create_email.show(create_email)


      AlumNet.execute('render:admin:emails:submenu', undefined, 0)
