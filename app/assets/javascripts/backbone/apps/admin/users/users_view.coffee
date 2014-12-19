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
        

  class Users.ModalStatus extends Backbone.Modal
    template: 'admin/users/templates/modal_status'        

    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-status"

    events:
      'click #save-status': 'saveStatus'

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      
      if data.status == "1"        
        id = @model.id
        url = AlumNet.api_endpoint + "/admin/users/#{id}/activate"

        Backbone.ajax
          url: url
          type: "PUT"
          success: (data) =>
            #Update the model and re-render the itemView
            @model.fetch()
            # window.nelson = @model
            # console.log window.model

          complete: (p, s) ->
            # console.log p
            # console.log s   

    # templateHelpers: () ->
      # isApproved: () ->
      # isApproved: () ->
      #   console.log "si va"      
      #   "yeh"
    
    # serializeData: (model)->
    #   console.log "hagdg"
    #   console.log model  


  class Users.ModalPlan extends Backbone.Modal
    template: 'admin/users/templates/modal_plan'    
    
    viewContainer: '.my-container'
    cancelEl: '#close-btn'
    submitEl: "#save-status"
    


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
             
      getAge: ()->                  
        moment().diff(@profileData.born, 'years')        
                
      getJoinTime: ()->            
        moment(@created_at).fromNow()   
        
      getOriginLocation: ()->            
        "#{@profileData.birth_city.text} - #{@profileData.birth_country.text}"


    showActions: (e)->
      e.stopPropagation()
      e.preventDefault()
      
      modalsView = new Users.ModalActions        
        model: @model
        modals: @modals

      @modals.show(modalsView)


  class Users.UsersTable extends Marionette.CompositeView
    template: 'admin/users/templates/users_container'
    childView: Users.UserView
    childViewContainer: "#users-table tbody"
    initialize: (options) ->
      @modals = options.modals      

    childViewOptions: (model, index) ->      
      modals: @modals 



  ###Filters views###
  class Users.Filter extends Marionette.CompositeView
    template: 'admin/users/templates/filter'
    tagName: "form"

  class Users.Filters extends Marionette.CompositeView
    template: 'admin/users/templates/filters_container'
    
    childView: Users.Filter
    childViewContainer: "#js-filters"

    ui:
      'btnAdd': '.js-addRow'      

    events:
      "click @ui.btnAdd": "addRow"


    addRow: (e)->
      newFilter = new AlumNet.Entities.Filter        
      @collection.add(newFilter)  

    # initialize: (options) ->
    #   @modals = options.modals      
    
