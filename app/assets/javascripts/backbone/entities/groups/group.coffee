@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Group extends Backbone.Model
    urlRoot: 'http://localhost:4000/groups'
    validation:
      name:
        required: true
      description:
        required: true
      avatar:
        required: true


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
    getNewGroup: ->
      new Entities.Group
    findGroup: (id)->
      group = new Entities.Group
        id: id
      group.fetch
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success', response, options)
      group


  AlumNet.reqres.setHandler 'group:new', ->
    API.getNewGroup()

  AlumNet.reqres.setHandler 'group:entities', ->
    API.getGroupEntities()

  AlumNet.reqres.setHandler 'group:find', (id)->
    API.findGroup(id)
