@AlumNet.module 'FriendsApp.Import', (Import, @AlumNet, Backbone, Marionette, $, _) ->

  class Import.Contacts extends Marionette.ItemView
    template: 'friends/import/templates/import_container'

  
  class Import.Networks extends Marionette.ItemView
    template: 'friends/import/templates/import_networks'