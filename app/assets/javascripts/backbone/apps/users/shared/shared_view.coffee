@AlumNet.module 'UsersApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'users/shared/templates/header'  

    ui:
      "editPic": "#js-editPic"  
      "modalCont": "#js-picture-modal-container"  
      'requestLink': '#js-request-send'   #Id agregado

    events:
      "click @ui.editPic": "editPic"
      'click #js-request-send':'sendRequest' #Evento agregado

    modelEvents:
      "change": "modelChange"

    
    initialize: (options)->
      @userCanEdit = options.userCanEdit


    templateHelpers: ->                  
      model = @model
      userCanEdit: @userCanEdit
      console.log model
      
      position: ->
        model.profile.get("last_experience") ? "No Position"

    modelChange: ->
      @render()     

    editPic: (e)-> 
      e.preventDefault()
      modal = new AlumNet.UsersApp.About.ProfileModal
        view: this
        type: 3
        model: @model.profile

      @ui.modalCont.html(modal.render().el)

    coverChanged: ->
      cover = @model.get('cover')
      @ui.coverArea.css('background-image',"url('#{cover.main}'")  

    sendRequest: (e)->
      attrs = { friend_id: @model.id }
      friendship = AlumNet.request('current_user:friendship:request', attrs)
      friendship.on 'save:success', (response, options) =>                   
        @model.fetch()

    sendMessage: (e)->    
                
                   
        
    
  class Shared.Layout extends Marionette.LayoutView
    template: 'users/shared/templates/layout'

    regions:
      header: '#user-header'
      body: '#user-body'

    initialize: (options) ->      
      @tab = options.tab      
      @class = ["", "", ""
        "", ""
      ]  
      @class[parseInt(@tab)] = "--active"

    templateHelpers: ->
      classOf: (step) =>
        @class[step]  

  API =
    getUserLayout: (model, tab)->
      new Shared.Layout
        model: model
        tab: tab

    getUserHeader: (model, options)->
      options = _.extend options, model: model      
      new Shared.Header options    
        

  AlumNet.reqres.setHandler 'user:layout', (model, tab) ->
    API.getUserLayout(model, tab)

  AlumNet.reqres.setHandler 'user:header', (model, options = {})->
    API.getUserHeader(model, options)