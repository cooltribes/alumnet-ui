@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Approval extends Backbone.Model

  class Entities.ApprovalCollection extends Backbone.Collection
    model: Entities.Approval

  API =
    requestForApproval: (userId)->
      approval = new Entities.Approval
      approval.urlRoot = AlumNet.api_endpoint + '/me/approval_requests'
      approval.save {approver_id: userId},
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      approval


  

  AlumNet.reqres.setHandler 'current_user:approval:request', (userId) ->
    API.requestForApproval(userId)