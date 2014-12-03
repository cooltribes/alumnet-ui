@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Group extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups/'

    initialize: ->
      @posts = new Entities.PostCollection
      @posts.url = @urlRoot() + @id + '/posts'
      @permissions = @get('permissions')

    canEditInformation: ->
      if @permissions
        permissions.can_edit_information
      else
        false

    userCanInvite: ->
      if @permissions
        permissions.can_invite_users
      else
        false

    userCanCreateSubGroup: ->
      if @permissions
        permissions.can_create_subgroups
      else
        false

    userCanPost: ->
      if @permissions then true else false

    userCanComment: ->
      if @permissions then true else false

    validation:
      name:
        required: true
      description:
        required: true
      cover:
        required: true
      country_id:
        msg: 'Country is required'
        required: true
      city_id:
        msg: 'City is required'
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

    getNewSubGroup: (group_id)->
      subgroup = new Entities.Group
      subgroup.urlRoot = AlumNet.api_endpoint + '/groups/' + group_id + '/add_group'
      subgroup

    findGroup: (id)->
      if Entities.groups == undefined
        @findGroupOnApi(id)
      else
        @findGroupOnCollection(id)

    findGroupOnCollection: (id)->
      group = Entities.groups.get(id)
      if group == undefined
        group = @findGroupOnApi(id)
      group

    findGroupOnApi: (id)->
      group = new Entities.Group
        id: id
      group.fetch
        async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      group

  AlumNet.reqres.setHandler 'group:join:send', (group_id) ->
    API.createJoinGroup(group_id)

  AlumNet.reqres.setHandler 'group:new', ->
    API.getNewGroup()

  AlumNet.reqres.setHandler 'subgroup:new',(group_id) ->
    API.getNewSubGroup(group_id)

  AlumNet.reqres.setHandler 'group:entities', (querySearch) ->
    API.getGroupEntities(querySearch)

  AlumNet.reqres.setHandler 'group:find', (id)->
    API.findGroup(id)
