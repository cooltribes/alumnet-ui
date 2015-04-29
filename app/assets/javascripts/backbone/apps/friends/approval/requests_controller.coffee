@AlumNet.module 'FriendsApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->
  class Approval.Controller
    showReceived: (layout)->
      requestsCollection = AlumNet.request('current_user:approval:received')

      requestsView = new AlumNet.FriendsApp.Approval.RequestsView
        collection: requestsCollection

      requestsCollection.on "sync:complete", (collection)->
        #Sync counter
        approvalCount = requestsCollection.length
        layout.model.setCount("pending_approval_requests", approvalCount)


      requestsView.on 'childview:accept', (childView)->
        request = childView.model
        request.save {},
          success: ()->
            requestsCollection.remove(request)
            layout.model.decrementCount('pending_approval_requests')
        

      requestsView.on 'childview:decline', (childView)->
        request = childView.model
        request.destroy
          success: ()->
            layout.model.decrementCount('pending_approval_requests')
        
      layout.body.show(requestsView)