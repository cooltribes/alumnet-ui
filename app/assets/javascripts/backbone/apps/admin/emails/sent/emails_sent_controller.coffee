@AlumNet.module 'AdminApp.EmailsSent', (EmailsSent, @AlumNet, Backbone, Marionette, $, _) ->
  class EmailsSent.Controller
    emailsSent: ->

      collection = new Backbone.Collection [
        name: "Diana"
        ,
        name: "Nelson"
      ]

      layout = new EmailsSent.Layout
      
      sent_table = new EmailsSent.Table
      	collection: collection

      AlumNet.mainRegion.show(layout)
      layout.tableSentEmails.show(sent_table)

      AlumNet.execute('render:admin:emails:submenu', undefined, 1)
