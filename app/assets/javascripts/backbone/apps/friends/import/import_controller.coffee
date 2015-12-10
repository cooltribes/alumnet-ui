@AlumNet.module 'FriendsApp.Import', (Import, @AlumNet, Backbone, Marionette, $, _) ->
  class Import.Controller
    importContacts: ->
      page = new Import.Contacts
      AlumNet.mainRegion.show(page)
      #AlumNet.execute('render:friends:submenu', undefined, 2)
