@AlumNet.module 'AdminApp.EmailsSegment', (EmailsSegment, @AlumNet, Backbone, Marionette, $, _) ->
  class EmailsSegment.Controller
    emailsSegment: ->

      collection = new Backbone.Collection [
        name: "Diana"
        ,
        name: "Nelson"
      ]

      layout = new EmailsSegment.Layout
      
      sent_table = new EmailsSegment.Table
      	collection: collection

      AlumNet.mainRegion.show(layout)
      layout.tableSegment.show(sent_table)

      AlumNet.execute('render:admin:emails:submenu', undefined, 2)
