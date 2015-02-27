@AlumNet.module 'PrivacyApp.Settings', (Settings, @AlumNet, Backbone, Marionette, $, _) ->
  class Settings.Controller
    showPrivacy: ->
      AlumNet.execute('render:users:submenu')

      #Fetch the collection
      privCollection = new AlumNet.Entities.PrivacyCollection
      privCollection.comparator = "id"
      privCollection.fetch()



      privacyView = new Settings.View
        collection: privCollection


      AlumNet.mainRegion.show(privacyView)