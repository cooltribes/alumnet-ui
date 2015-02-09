@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.Committee extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/committees'

  class Entities.Committees extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/committees'
    model: Entities.Committee

  API =
    getCommittees: (country_id, query)->
      committees = new Entities.Committees
      committees.url = AlumNet.api_endpoint + '/countries/' + country_id + '/committees'
      committees.fetch({async: false, data: query})
      committees.map (model)->
        id: model.id
        text: model.get('name')

    getInternationalCommittees: ()->
      query = { q: { committee_type_eq: "International" } }
      committees = new Entities.Committees
      committees.url = AlumNet.api_endpoint + '/committees'
      committees.fetch({async: false, data: query})
      committees.map (model)->
        id: model.id
        text: model.get('name')


  AlumNet.reqres.setHandler 'get:committees', (country_id, query) ->
    API.getCommittees(country_id, query)

  AlumNet.reqres.setHandler 'get:committees:international', ->
    API.getInternationalCommittees()
