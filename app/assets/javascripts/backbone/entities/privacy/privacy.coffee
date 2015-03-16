@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.PrivacyAction extends Backbone.Model
    validation:
      value:
        range: [0,2]
        msg: "Please select a valid privacy option"
    

  class Entities.PrivacyCollection extends Backbone.Collection
    model: Entities.PrivacyAction
    url: ->
      AlumNet.api_endpoint + '/me/privacies'

