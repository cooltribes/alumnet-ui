@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Group extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups/'

    initialize: ->
      @posts = new Entities.PostCollection
      @posts.url = @urlRoot() + @id + '/posts'

    canEditInformation: ->
      permissions = this.get('permissions')
      if permissions
        permissions.can_edit_information
      else
        false

    validation:
      name:
        required: true
      description:
        required: true
      cover:
        required: true

  class Entities.GroupCollection extends Backbone.Collection
    model: Entities.Group

    url: ->
      AlumNet.api_endpoint + '/groups'

  class Entities.JoinGroup extends Backbone.Model
    url: ->
      AlumNet.api_endpoint + '/groups/' + @get('group_id') + '/join'

  initializeGroups = ->
    Entities.groups = new Entities.GroupCollection

  API =
    createJoinGroup: (group_id)->
      join = new Entities.JoinGroup
      join.save group_id,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      join

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

  AlumNet.reqres.setHandler 'group:join:send', (group_id) ->
    API.createJoinGroup(group_id)

  AlumNet.reqres.setHandler 'group:new', ->
    API.getNewGroup()

  AlumNet.reqres.setHandler 'group:entities', (querySearch) ->
    API.getGroupEntities(querySearch)

  AlumNet.reqres.setHandler 'group:find', (id)->
    API.findGroup(id)
