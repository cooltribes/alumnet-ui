@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Users.Layout extends Marionette.LayoutView
    template: 'admin/users/templates/layout'    
    className: 'container'
    regions:
      modals: 
        selector: '#modals-region' 
        regionClass: Backbone.Marionette.Modals
      filters: '#filters-region'  
      main: '#table-region'  


  #----Modal principal con las acciones
  class Users.ModalActions extends Backbone.Modal
    template: 'admin/users/templates/modal_actions'    

    cancelEl: '#close-btn'
    submitEl: "#save-status"

    events:
      'click #editStatus': 'openStatus'
      
    initialize: (options) ->
      @modals = options.modals
      
    openStatus: (e) ->
      e.preventDefault();
      statusView = new Users.ModalStatus
        model: @model
        modals: @modals

      @modals.show(statusView);
        

    
    templateHelpers: () ->
      model = @model
      profile: ()->
        console.log model
        model.profile


  class Users.ModalStatus extends Backbone.Modal
    template: 'admin/users/templates/modal_status'    
    
    viewContainer: '.my-container'
    cancelEl: '#close-btn'
    submitEl: "#save-status"
    



    templateHelpers: () ->
      model = @model
      profile: ()->
        console.log model
        model.profile


  class Users.ModalPlan extends Backbone.Modal
    template: 'admin/users/templates/modal_plan'    
    
    viewContainer: '.my-container'
    cancelEl: '#close-btn'
    submitEl: "#save-status"
    
    templateHelpers: () ->
      model = @model
      profile: ()->
        console.log model
        model.profile


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
      
      modalsView = new Users.ModalActions        
        model: @model
        modals: @modals

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


  class Users.Filters extends Marionette.CompositeView
    template: 'admin/users/templates/filters_container'
    
    # childView: Users.UserView
    # childViewContainer: "#users-table tbody"
    # initialize: (options) ->
    #   @modals = options.modals      

    # childViewOptions: (model, index) ->      
    #   modals: @modals      
