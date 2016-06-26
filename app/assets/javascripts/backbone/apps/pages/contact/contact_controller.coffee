@AlumNet.module 'PagesApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->
  class Contact.Controller
    showContact: ->
      page = new Contact.View
      AlumNet.mainRegion.show(page)
      AlumNet.execute 'show:footer'
      #AlumNet.execute('render:pages:submenu')