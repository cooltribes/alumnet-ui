@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Users.Layout extends Marionette.LayoutView
    template: 'admin/users/templates/layout'    
    className: 'container-fluid'
    regions:
      modals: 
        selector: '#modals-region' 
        regionClass: Backbone.Marionette.Modals
      filters: '#filters-region'  
      main: '#table-region'  


  class Users.Modals extends Backbone.Modal
    template: 'admin/users/templates/modals'    
    
    viewContainer: '.my-container'
    cancelEl: '#close-btn'

    # ui:
    #   'btnEdit': '.js-edit'
    # events:
    #   'click @ui.btnEdit': 'showActions'
    initialize: (options) ->
      console.log "nelson"
      console.log options
      # status = 
      #   id: 0
      #   text: "Inactive"
    
    templateHelpers: () ->
      model = @model
      profile: ()->
        console.log model
        model.profile
   
    views:
      'click #actions':
        view: 'admin/users/templates/modal_actions'
        name: 'actions'
        # model: @model
        # onActive: 'setActive'
      'click #editStatus':
        view: 'admin/users/templates/modal_status'
        name: 'user_status'
        # model: @model
        # profile: @model.profile
        # onActive: 'setActive'


  class Users.UserView extends Marionette.ItemView
    template: 'admin/users/templates/user'
    tagName: "tr"
    ui:
      'btnEdit': '.js-edit'
    events:
      'click @ui.btnEdit': 'showActions'

    initialize: (options) ->
      @modals = options.modals

    templateHelpers: () ->
      model = @model      
      getAge: ()->            
        moment().diff(model.profile.get("born"), 'years')        
      getJoinTime: ()->            
        moment(model.profile.get("created_at")).fromNow()
        

    # serializeData: ()->    
    #   data = {}

    #   data = _.extend(data, @model.toJSON()) if @model
    #   data = _.extend(data, {items: @collection.toJSON()}) if @collection
    #   return data


    showActions: (e)->
      e.stopPropagation()
      e.preventDefault()
      
      modalsView = new Users.Modals
        name: "actions"
        model: @model

      @modals.show(modalsView)

      # @trigger 'click:leave'
      #Modals view
      
      # layoutView.modals.show(modalsView)

  class Users.UsersTable extends Marionette.CompositeView
    template: 'admin/users/templates/users_container'
    childView: Users.UserView
    childViewContainer: "#users-table tbody"
    initialize: (options) ->
      @modals = options.modals      

    childViewOptions: (model, index) ->      
      modals: @modals      