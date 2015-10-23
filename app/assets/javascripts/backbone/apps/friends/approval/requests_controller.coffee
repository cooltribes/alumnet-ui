@AlumNet.module 'FriendsApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->
  class Approval.Controller extends AlumNet.Controllers.Base
    showReceived: ()->

      current_user = AlumNet.current_user

      AlumNet.execute('render:friends:submenu',undefined, 3)

      requestsCollection = AlumNet.request('current_user:approval:received')

      requestsView = new AlumNet.FriendsApp.Approval.RequestsView
        collection: requestsCollection

      requestsCollection.on "sync:complete", (collection)->
        approvalCount = requestsCollection.length


      requestsView.on 'childview:accept', (childView)->
        request = childView.model
        request.save {},
          success: ()->
            requestsCollection.remove(request)


      requestsView.on 'childview:decline', (childView)->
        request = childView.model
        request.destroy
          success: ()->

      AlumNet.mainRegion.show requestsView
