@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Group extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups'

    initialize: ()->
      @posts = new Entities.GroupPostCollection({ group_id: @id })

    canEditInformation: ->
      membership = this.get('membership')
      if membership
        membership.edit_information == 1 ? true : false
      else
        false

    validation:
      name:
        required: true
      description:
        required: true
      avatar:
        required: true


  class Entities.GroupCollection extends Backbone.Collection
    model: Entities.Group

    url: ->
      AlumNet.api_endpoint + '/groups'

  initializeGroups = ->
    Entities.groups = new Entities.GroupCollection

  API =
    getGroupEntities: (querySearch)->
      initializeGroups() if Entities.groups == undefined
      Entities.groups.fetch
        data: querySearch
      Entities.groups
    getNewGroup: ->
      new Entities.Group
    findGroup: (id)->
      #Optimize: Verify if Entities.groups is set and find the group there.
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

  AlumNet.reqres.setHandler 'group:entities', (querySearch) ->
    API.getGroupEntities(querySearch)

  AlumNet.reqres.setHandler 'group:find', (id)->
    API.findGroup(id)
