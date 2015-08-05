@AlumNet.module 'RegistrationApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->

  class Approval.Controller

    activateUser: ->
      Backbone.ajax
        url: AlumNet.api_endpoint + "/me/activate"
        method: "post"
        success: (data)->
          if data.status == "active"
            AlumNet.current_user.fetch
              success: ->
                if AlumNet.current_user.profile.get('role') == "External"
                  AlumNet.headerRegion.reset()
                  alert "Hola Externo!"
                else
                  AlumNet.headerRegion.reset()
                  AlumNet.navigate("posts", { trigger: true })
          else
            console.log "nop"
            $.growl.error { message: data.status }

    showApproval: ->
      # creating layout
      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSideView())

      #Getting the entire collection of users
      # users = AlumNet.request('user:entities', {})
      users = AlumNet.request('user:entities', {}, {fetch: true})
      users.on "fetch:success", ->
        if users.length > 3
          users.set(users.slice(0,3))

      approvalView = @getFormView users,true
      layoutView.form_region.show(approvalView)

      approvalView.on 'users:search', (querySearch)->
        AlumNet.request('user:entities', querySearch)
        #users.on "fetch:success", ->
        #  console.log users.length 

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

    getFormView: (users,bandera) ->
      current_user = AlumNet.current_user

      new Approval.Form
        model: current_user
        collection: users
        bandera: bandera