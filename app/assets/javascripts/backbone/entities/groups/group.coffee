@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Group extends Backbone.Model
    prueba: ->
      "Hola Armando"

  class Entities.GroupCollection extends Backbone.Collection
    url: 'http://localhost:4000/groups'
    model: Entities.Group

  initializeGroups = ->
    Entities.groups = new Entities.GroupCollection

  API =
    getGroupEntities: ->
      initializeGroups() if Entities.groups == undefined
      Entities.groups.fetch()
      Entities.groups

  AlumNet.reqres.setHandler 'group:entities', ->
    API.getGroupEntities()
