@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Keyword extends Backbone.Model

  class Entities.KeywordsCollection extends Backbone.Collection
    model: Entities.Keyword
    # url: -> 
    #   AlumNet.api_endpoint + "/keywords"


  
