@AlumNet.module 'RegistrationApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Shared.Sidebar extends Marionette.ItemView
    template: 'registration/shared/templates/sidebar'
    
    initialize: (options) ->
      @step = options.step || ""
      # console.log "options sidebar"
      # console.log options
      @class = [
        "", "", ""
        "", ""
      ]  

      @class[@step - 1] = "--active"      

    templateHelpers: ->
      classOf: (step) =>
        @class[step]


  class Shared.Layout extends Marionette.LayoutView
    template: 'registration/shared/templates/layout'
    id: ''
    className: 'container-fluid'
    regions:
      side_region: '#sidebar-region' 
      form_region: '#form-region'

  # initializeLayout = ->
  #   Shared.layout = new Shared.Layout

  # initializeHeader = (model) ->
  #   Shared.header = new Shared.Header
  #     model: model

  # class Shared.Count extends Marionette.ItemView
  #   template: 'registration/shared/templates/sidebar'
    
    # templateHelpers: ->
    #   canEditInformation: this.model.canEditInformation()
    # ui:
    #   'groupName':'#name'
    # onRender: ->
    #   model = this.model
    #   @ui.groupName.editable
    #     type: "text"
    #     pk: model.id
    #     title: "Ente Name"
    #     success: (response, newValue)->
    #       alert newValue

  API =
    getSidebarView: (step)->
      # Contarle a nelson que las vistas se destruyen. Por lo tanto no se puede usar la misma instancia
      # initializeLayout() if Shared.layout == undefined
      # Shared.layout
      new Shared.Sidebar
        step: step

    getLayoutView: (model)->
      # initializeHeader(model) if Shared.header == undefined
      # Shared.header
      new Shared.Layout        

  AlumNet.reqres.setHandler 'registration:shared:layout', ->
    API.getLayoutView()

  AlumNet.reqres.setHandler 'registration:shared:sidebar', (step) ->
    API.getSidebarView(step)