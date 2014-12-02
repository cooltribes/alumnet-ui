@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Entities.Country extends Backbone.Model    
    urlRoot: ->
      AlumNet.api_endpoint + '/countries/'

  class Entities.Countries extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/countries'
    model: Entities.Country


  class Entities.City extends Backbone.Model    
    urlRoot: ->
      AlumNet.api_endpoint + '/countries/'

  class Entities.Cities extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/countries'
    model: Entities.City



  API =

    getCountriesHtml: (collection)  ->
      html = '<option value="">Select a country</option>'            

      _.forEach collection.models, (item, index, list)->        
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>' 

      html

    getCities: (countryId)->
      collection = new Entities.Cities
      collection.url = AlumNet.api_endpoint + '/countries/' + countryId + '/cities'
      collection

    getCitiesHtml: (collection)->  
      html = '<option value="">Select a city</option>'            

      _.forEach collection.models, (item, index, list)->        
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>' 

      html


  AlumNet.reqres.setHandler 'countries:html', (collection) ->
    API.getCountriesHtml(collection)

  AlumNet.reqres.setHandler 'cities:html', (collection) ->
    API.getCitiesHtml(collection)  

  AlumNet.reqres.setHandler 'cities:get_cities', (countryId) ->
    API.getCities(countryId)  
  
