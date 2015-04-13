@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.Region extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/admin/regions/'

    countries: ->
      @get('countries')

  class Entities.Regions extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/admin/regions/'
    model: Entities.Region

  API =
    getRegions: ()->
      new Entities.Regions


  AlumNet.reqres.setHandler 'get:regions', ->
    API.getRegions()
