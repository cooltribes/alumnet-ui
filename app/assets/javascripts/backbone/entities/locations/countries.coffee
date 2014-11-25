@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Entities.Country extends Backbone.Model    
    urlRoot: ->
      AlumNet.api_endpoint + '/countries/'

  class Entities.Countries extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/countries'
    model: Entities.Country

  API =
    getCountriesHtml: (collection)  ->
      html = '<option value="">Select a country</option>'            

      # console.log "inside"
      # console.log collection.length
      _.forEach collection.models, (item, index, list)->
        console.log "cada uno"
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>' 

      html


  AlumNet.reqres.setHandler 'countries:html', (collection) ->
    API.getCountriesHtml(collection)

  
