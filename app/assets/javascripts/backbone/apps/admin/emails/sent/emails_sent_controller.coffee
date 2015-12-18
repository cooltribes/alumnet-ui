@AlumNet.module 'AdminApp.EmailsSent', (EmailsSent, @AlumNet, Backbone, Marionette, $, _) ->
  class EmailsSent.Controller
    emailsSent: ->

      layout = new EmailsSent.Layout
      search =  new EmailsSent.Search
      sent_table = new EmailsSent.Table


      AlumNet.mainRegion.show(layout)
      layout.search.show(search)
      layout.table.show(sent_table)


      AlumNet.execute('render:admin:emails:submenu', undefined, 0)
