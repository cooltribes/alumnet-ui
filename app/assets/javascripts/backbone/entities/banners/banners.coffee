@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Banner extends Backbone.Model
    urlRoot: -> 
      AlumNet.api_endpoint + '/banners/'


  class Entities.BannerCollection extends Backbone.Collection
  
    model: Entities.Banner
  
    url: -> 
      AlumNet.api_endpoint + '/banners/'
  