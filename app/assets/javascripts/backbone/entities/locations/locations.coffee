@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  
  # Country
  class Entities.Country extends Backbone.Model    
    urlRoot: ->
      AlumNet.api_endpoint + '/countries/'

  class Entities.Countries extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/countries'
    model: Entities.Country


  # Cities
  class Entities.City extends Backbone.Model        

  class Entities.Cities extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/countries'
    model: Entities.City
  

  class Entities.Committee extends Backbone.Model    

  class Entities.Committees extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/countries'
    model: Entities.Committee



  API =

    getCountriesHtml: (collection)  ->
      html = '<option value="">Select a country</option>'            

      _.forEach collection.models, (item, index, list)->        
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>' 
      html

    getCitiesHtml: (collection)->  
      html = '<option value="">Select a city</option>'            

      _.forEach collection.models, (item, index, list)->        
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>' 
      html

    getCommitteesHtml: (collection)->  
      html = '<option value="">Select a committee</option>'            

      _.forEach collection.models, (item, index, list)->        
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>' 
      html

    getCities: (countryId)->
      collection = new Entities.Cities
      collection.url = AlumNet.api_endpoint + '/countries/' + countryId + '/cities'
      collection
    
    getCommmittees: (countryId)->
      collection = new Entities.Committees
      collection.url = AlumNet.api_endpoint + '/countries/' + countryId + '/committees'
      collection


  AlumNet.reqres.setHandler 'countries:html', (collection) ->
    API.getCountriesHtml(collection)

  AlumNet.reqres.setHandler 'cities:html', (collection) ->
    API.getCitiesHtml(collection)  

  AlumNet.reqres.setHandler 'committees:html', (collection) ->
    API.getCommitteesHtml(collection)  

  AlumNet.reqres.setHandler 'cities:get_cities', (countryId) ->
    API.getCities(countryId)

  AlumNet.reqres.setHandler 'cities:get_committees', (countryId) ->
    API.getCommmittees(countryId)  
  
