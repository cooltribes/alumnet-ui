@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Company extends Backbone.Model
    urlRoot: -> 
      AlumNet.api_endpoint + "/companies"
    
    validation:
      name:
        required: true

    
      

        