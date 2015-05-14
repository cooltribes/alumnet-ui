@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Banner extends Backbone.Model
    urlRoot: -> 
      AlumNet.api_endpoint + '/banners/'

    defaults:
      activeSlide: false  
    ###
    validation: 
      title:
        required: true
        maxLength: 250
        msg: "Banner title is required, must be less than 250 characters long."
      link:
        required: true
        maxLength: 250
        msg: "Banner link is required, must be less than 250 characters long."  
      description:
        required: true
        maxLength: 2048
        msg: "Banner description is required, must be less than 2048 characters"
      picture:
        required: true 
    ###

  class Entities.BannerCollection extends Backbone.Collection
    model: Entities.Banner
  
    url: -> 
      AlumNet.api_endpoint + '/banners'

  API =    
    getBannerEntities: ->
      new Entities.Banner 
      
  AlumNet.reqres.setHandler 'banner:entities', ->
    API.getBannerEntities()   
   
      
  