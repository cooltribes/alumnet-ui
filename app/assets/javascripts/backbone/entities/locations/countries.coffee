@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.Country extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/countries/'

  class Entities.Countries extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/countries'
    model: Entities.Country

  initializeCountries = ->
    Entities.countries = new Entities.Countries
    Entities.countries.fetch({async: false})

  API =
    getCountriesHtml: (collection)  ->
      html = '<option value="">Select a country</option>'

      _.forEach collection.models, (item, index, list)->
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>'

      html

    getCountries: ()->
      initializeCountries() if Entities.countries == undefined
      Entities.countries

    getAiesecCountries: ()->
      @getCountries()
      Entities.countries.where(aiesec: true)

  AlumNet.reqres.setHandler 'countries:html', (collection) ->
    API.getCountriesHtml(collection)

  AlumNet.reqres.setHandler 'get:countries', ->
    API.getCountries()

  AlumNet.reqres.setHandler 'get:aiesec_countries', ->
    API.getAiesecCountries()

  class CountryList
    window.CountryList =
      toSelect2: ->
        countries = AlumNet.request 'get:countries'
        countries.map (model)->
          id: model.id
          text: model.get('name')

  class CountryList
    window.CountryAiesecList =
      toSelect2: ->
        countries = AlumNet.request 'get:aiesec_countries'
        countries.map (model)->
          id: model.id
          text: model.get('name')

