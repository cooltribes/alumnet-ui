@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Approval extends Backbone.Model

  class Entities.ApprovalCollection extends Backbone.Collection
    model: Entities.Approval
    rows: 6
    page: 1

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

    getPendingRequests: (attrs)->
      approval_request = new Entities.ApprovalCollection
      approval_request.url = AlumNet.api_endpoint + '/me/approval_requests'
      approval_request.fetch
        data: { page: approval_request.page,per_page: approval_request.rows }
        success: (collection)->
          collection.trigger("sync:complete", collection)
      approval_request
  

  AlumNet.reqres.setHandler 'current_user:approval:request', (userId) ->
    API.requestForApproval(userId)

   AlumNet.reqres.setHandler 'current_user:approval:received', (userId) ->
    API.getPendingRequests(userId)

