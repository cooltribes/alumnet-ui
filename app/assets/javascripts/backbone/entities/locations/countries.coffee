@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Entities.Country extends Backbone.Model    
    urlRoot: ->
      AlumNet.api_endpoint + '/countries/'

  class Entities.Countries extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/countries'
    model: Entities.Country

  
