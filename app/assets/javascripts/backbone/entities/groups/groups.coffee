@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Group extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups/'

    initialize: ->
      @posts = new Entities.PostCollection
      @posts.url = @urlRoot() + @id + '/posts'
      @subgroups = new Entities.GroupCollection
      @subgroups.url = @urlRoot() + @id + '/subgroups'

    userIsAdmin: ->
      @get('admin')

    canDo: (permission) ->
      permissions = @get('permissions')
      if permissions and permissions[permission] > 0
        true
      else
        false

    userCanInvite: ->
      status = @get('membership_status')
      if status == "approved"
        join_process = @get('join_process')
        admin = @get('admin')
        switch join_process
          when 0, 1
            true
          when 2
            if admin then true else false
          else
            false
      else
        false

    userIsMember: ->
      status = @get('membership_status')
      status == "approved"

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
      join_process:
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
      group = @findGroupOnApi(id)
      # initializeGroups() if Entities.groups == undefined
      # group = Entities.groups.get(id)
      # if group == undefined
      # group

      # if Entities.groups == undefined
      #   @findGroupOnApi(id)
      # else
      #   @findGroupOnCollection(id)

    findGroupOnCollection: (id)->
      group = Entities.groups.get(id)
      if group == undefined
        group = @findGroupOnApi(id)
      group

    findGroupOnApi: (id)->
      group = new Entities.Group
        id: id
      group.fetch
        # async: false
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
