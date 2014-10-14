@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Group extends Backbone.Model
    #url: 'http://localhost:4000/groups'

  class Entities.GroupCollection extends Backbone.Collection
    #url: 'http://localhost:4000/groups'
    model: Entities.Group

  initializeGroups = ->
    Entities.groups = new Entities.GroupCollection [
      {name: "dagd", description: "adgdgg"}
    ]

  API =
    getGroupEntities: ->
      initializeGroups() if Entities.groups == undefined
      #Entities.groups.fetch()
      Entities.groups
    getNewGroup: ->
      Entities.group = new Entities.Group

  AlumNet.reqres.setHandler 'group:new', ->
    API.getNewGroup()

  AlumNet.reqres.setHandler 'group:entities', ->
    API.getGroupEntities()
