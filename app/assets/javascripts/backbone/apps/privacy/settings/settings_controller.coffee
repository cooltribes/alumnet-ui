@AlumNet.module 'PrivacyApp.Settings', (Settings, @AlumNet, Backbone, Marionette, $, _) ->
  class Settings.Controller
    showPrivacy: ->
      AlumNet.execute('render:users:submenu')

      #Fetch the collection
      privCollection = new AlumNet.Entities.PrivacyCollection
      privCollection.comparator = "id"
      privCollection.fetch
        success: (collection)->
          #Get the last one and insert one fake model for contact info
          # collection.at(collection.length - 1)
          collection.add
            description: "Who can see my contact information"
            value: -1



      privacyView = new Settings.View
        collection: privCollection


      AlumNet.mainRegion.show(privacyView)