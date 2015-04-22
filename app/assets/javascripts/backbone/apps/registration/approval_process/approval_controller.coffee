@AlumNet.module 'RegistrationApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Approval.Controller

    showApproval: ->
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSideView())
      
      #Getting the entire collection of users
      users = AlumNet.request('user:entities', {})      
      # users = AlumNet.request('user:entities', {}, {fetch: false})      
      
      approvalView = @getFormView users
      layoutView.form_region.show(approvalView)    

      approvalView.on 'users:search', (querySearch)->
        AlumNet.request('user:entities', querySearch)  

      approvalView.on 'childview:request', (childView)->
        childView.ui.actionsContainer.html('Sending request...')
        childView.ui.actionsContainer.html('Your request has been sent <span class="icon-entypo-paper-plane"></span>')
        

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")  

    getSideView: ->
      AlumNet.request("registration:shared:sidebar", 5)

    getFormView: (users) ->
      new Approval.Form
        collection: users  