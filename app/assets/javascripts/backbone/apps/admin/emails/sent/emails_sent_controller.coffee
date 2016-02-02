@AlumNet.module 'AdminApp.EmailsSent', (EmailsSent, @AlumNet, Backbone, Marionette, $, _) ->
  class EmailsSent.Controller
    emailsSent: ->
      layout = new EmailsSent.Layout
      collection = new AlumNet.Entities.CampaignCollection
      collection.fetch
        success: ->
          sent_table = new EmailsSent.Table
          	collection: collection

          AlumNet.mainRegion.show(layout)
          layout.tableSentEmails.show(sent_table)

      AlumNet.execute('render:admin:emails:submenu', undefined, 1)
