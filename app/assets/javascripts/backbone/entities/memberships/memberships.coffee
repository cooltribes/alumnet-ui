@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Membership extends Backbone.Model

  class Entities.MembershipsCollection extends Backbone.Collection
    model: Entities.Membership

  API =
    sendMembershipInvitation: (attrs)->
      membership = new Entities.Membership(attrs)
      membership.urlRoot = AlumNet.api_endpoint + '/groups/' + attrs.group_id + '/memberships'
      membership.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      membership

    getGroupMembers: (group_id, querySearch)->
      members = new Entities.MembershipsCollection
      members.url = AlumNet.api_endpoint + '/groups/' + group_id + '/memberships/members'
      members.fetch
        data: querySearch
      members

    getUserGroups: (user_id, querySearch)->
      members = new Entities.MembershipsCollection
      members.url = AlumNet.api_endpoint + '/users/' + user_id + '/memberships/groups'
      members.fetch
        data: querySearch
      members

    sendMembershipRequest: (attrs)->
      current_user = AlumNet.request('temp:current_user')
      membership = new Entities.Membership(attrs)
      membership.urlRoot = AlumNet.api_endpoint + '/users/' + current_user.id + '/memberships'
      membership.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      membership


  AlumNet.reqres.setHandler 'membership:invitation', (attrs) ->
    API.sendMembershipInvitation(attrs)
  AlumNet.reqres.setHandler 'membership:request', (attrs) ->
    API.sendMembershipRequest(attrs)
  AlumNet.reqres.setHandler 'membership:members', (group_id, querySearch) ->
    API.getGroupMembers(group_id, querySearch)
  AlumNet.reqres.setHandler 'membership:groups', (user_id, querySearch) ->
    API.getUserGroups(user_id, querySearch)