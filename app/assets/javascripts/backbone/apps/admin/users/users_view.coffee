@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Users.Layout extends Marionette.LayoutView
    template: 'admin/users/templates/layout'    
    className: 'container-fluid'
    regions:
      modals: 
        selector: '#modals-region' 
        regionClass: Backbone.Marionette.Modals
      filters: '#filters-region'  
      main: '#main-region'  


  class Users.Modals extends Backbone.Modal
    template: 'admin/users/templates/modals'    
    className: 'container-fluid'
    viewContainer: '.my-container'

    regions:
      modals: 
        selector: '#modals-region' 
        regionClass: Backbone.Marionette.Modals
      filters: '#filters-region'  
      main: '#main-region'  
    
    views:
      'click #step1':
          view: 'admin/users/templates/modal_actions'


  class Users.UserView extends Marionette.ItemView
    template: 'admin/users/templates/user'
    tagName: "tr"
    # ui:
    #   'leaveGroupLink': '#js-leave-group'
    # events:
    #   'click #js-leave-group': 'clickedLeaveLink'

    initialize: ->
      # @model.profile.fetch()
        # console.log "vista init"
        # console.log this

    templateHelpers: ->
      getAge: ->      
        "24"
        # moment().diff(@profile.get("born"), 'years')


    # clickedLeaveLink: (e)->
    #   e.stopPropagation()
    #   e.preventDefault()
    #   @trigger 'click:leave'

  class Users.UsersTable extends Marionette.CompositeView
    template: 'admin/users/templates/users_container'
    childView: Users.UserView
    childViewContainer: "#users-table tbody"