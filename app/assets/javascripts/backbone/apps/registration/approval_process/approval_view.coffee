@AlumNet.module 'RegistrationApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->
  class Approval.UserView extends Marionette.ItemView
    template: 'registration/approval_process/templates/user'  

    ui:
      'requestBtn': '.js-ask'
      'actionsContainer': '.js-actions-container'
    
    events:
      'click @ui.requestBtn':'clickedRequest'
    
    clickedRequest: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request")
      

      
  class Approval.Form extends Marionette.CompositeView
    template: 'registration/approval_process/templates/form'  
    childView: Approval.UserView
    childViewContainer: '.users-list'

    ui:
      'adminRequestBtn': '.js-askAdmin'
    events:
      'click .js-search': 'performSearch'
      'click @ui.adminRequestBtn':'clickedRequestAdmin'


    clickedRequestAdmin: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request:admin")
      # console.log "RequestAdmin"  

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', @buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        profile_first_name_cont: searchTerm
        profile_last_name_cont: searchTerm
        email_cont: searchTerm