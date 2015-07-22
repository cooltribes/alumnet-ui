@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Group extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups/'

    initialize: ->
      @posts = new Entities.PostCollection
      @posts.url = @urlRoot() + @id + '/posts'
      @subgroups = new Entities.GroupCollection
      @subgroups.url = @urlRoot() + @id + '/subgroups'

    isOpen: ->
      group_type = @get('group_type')
      group_type.value == 0

    isClose: ->
      group_type = @get('group_type')
      group_type.value == 1

    isSecret: ->
      group_type = @get('group_type')
      group_type.value == 2

    userIsAdmin: ->
      @get('admin')

    hasMailchimp: ->
      mailchimp = @get('mailchimp')
      if(mailchimp)
        true
      else
        false

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

    userHasMembership: (user_id)->
      groupMemberships = @get('membership_users')
      _.contains(groupMemberships, user_id)

    userIsMember: ->
      status = @get('membership_status')
      status == "approved"

    canBeOfficial: ->
      @get("can_be_official")

    canBeUnOfficial: ->
      @get("can_be_unofficial")

    canHaveOfficialSubgroup: ->
      @get("official")

    # return representing string for upload_files value if param "value" is true
    # if "value" is false, return the entire list for use in dropdown, etc.
    uploadFilesText: (value = false)->
      values = [
        {value: 0, text: 'Only administrators'},
        {value: 1, text: 'All members'}
      ]
      if value
        values[ @get("upload_files").text ]          
      else
        values


      
    validation:
      name:
        required: true
        maxLength: 250
        msg: "Group name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Group description is required, must be less than 2048 characters"
      cover:
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

  class Entities.DeletedGroup extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/admin/deleted/groups/'

  class Entities.DeletedGroupCollection extends Backbone.Collection
    model: Entities.DeletedGroup

    url: ->
      AlumNet.api_endpoint + '/admin/deleted/groups/'


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
        success: (model, response, options) ->
          Entities.groups.trigger('fetch:success')
      Entities.groups

    getGroupsForAdmin: (querySearch)->
      groups = new Entities.GroupCollection
      groups.url = AlumNet.api_endpoint + '/admin/groups'
      groups.fetch
        data: querySearch
      groups

    getGroupsDeleted: (querySearch)->
      groups = new Entities.DeletedGroupCollection
      groups.fetch
        data: querySearch
      groups

    getSubGroupsForAdmin: (group_id)->
      subgroups = new Entities.GroupCollection
      subgroups.url = AlumNet.api_endpoint + '/admin/groups/' + group_id + '/subgroups'
      subgroups

    getNewGroup: ->
      new Entities.Group

    getNewSubGroup: (group_id)->
      subgroup = new Entities.Group
      subgroup.urlRoot = AlumNet.api_endpoint + '/groups/' + group_id + '/add_group'
      subgroup

    findGroup: (id)->
      group = @findGroupOnApi(id)

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

  AlumNet.reqres.setHandler 'group:entities:admin', (querySearch)->
    API.getGroupsForAdmin(querySearch)

  AlumNet.reqres.setHandler 'subgroups:entities:admin', (group_id)->
    API.getSubGroupsForAdmin(group_id)

  AlumNet.reqres.setHandler 'group:entities:deleted', (querySearch)->
    API.getGroupsDeleted(querySearch)
