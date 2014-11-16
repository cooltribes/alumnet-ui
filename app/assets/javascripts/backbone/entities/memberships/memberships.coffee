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


  AlumNet.reqres.setHandler 'membership:invitation', (attrs) ->
    API.sendMembershipInvitation(attrs)