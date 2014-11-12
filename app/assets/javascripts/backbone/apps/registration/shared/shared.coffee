@AlumNet.module 'RegistrationApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Shared.Sidebar extends Marionette.ItemView
    template: 'registration/shared/templates/sidebar'
    
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

  API =
    getSidebarView: ()->
      # Contarle a nelson que las vistas se destruyen. Por lo tanto no se puede usar la misma instancia
      # initializeLayout() if Shared.layout == undefined
      # Shared.layout
      new Shared.Sidebar

    getLayoutView: (model)->
      # initializeHeader(model) if Shared.header == undefined
      # Shared.header
      new Shared.Layout        

  AlumNet.reqres.setHandler 'registration:shared:layout', ->
    API.getLayoutView()

  AlumNet.reqres.setHandler 'registration:shared:sidebar', ->
    API.getSidebarView()