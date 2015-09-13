@AlumNet.module 'RegistrationApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->

  class Approval.Controller

    showApproval: ->
      # creating layout
      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSideView())

      #Getting the entire collection of users
      # users = AlumNet.request('user:entities', {})
      users = AlumNet.request('user:entities', {}, {fetch: false})

      approvalView = @getFormView users
      layoutView.form_region.show(approvalView)

      approvalView.on 'users:search', (querySearch)->
        AlumNet.request('user:entities', querySearch)

      approvalView.on 'contacts:search', (contacts)->
        approvalView.collection = new AlumNet.Entities.ContactsInAlumnet
        approvalView.collection.fetch({ method: 'POST', data: { contacts: contacts }})
        approvalView.render()

      approvalView.on 'request:admin', ()->
        url = AlumNet.api_endpoint + "/me/approval_requests/notify_admins"
        Backbone.ajax
          url: url
          type: "PUT"
          # success: (data) =>
          #   @model.set(data)
          #   @model.trigger 'change:role'
          # error: (data) =>
          #   text = data.responseJSON[0]
          #   $.growl.error({ message: text })


      approvalView.on 'childview:request', (childView)->
        childView.ui.actionsContainer.html('Sending request...')

        userId = childView.model.id
        approvalR = AlumNet.request("current_user:approval:request", userId)
        approvalR.on "save:success", ()->
          childView.ui.actionsContainer.html('Your request has been sent <span class="icon-entypo-paper-plane"></span>')


    getLayoutView: ->
      AlumNet.request("registration:shared:layout")

    getSideView: ->
      AlumNet.request("registration:shared:sidebar", 5)

    getFormView: (users) ->
      current_user = AlumNet.current_user

      new Approval.Form
        model: current_user
        collection: users