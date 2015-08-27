@AlumNet.module 'RegistrationApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Shared.Sidebar extends Marionette.ItemView
    template: 'registration/shared/templates/sidebar'
   
    initialize: (options) ->
      document.title = " AlumNet - Registration"
      @step = options.step || ""
      @class = [
        "", "", ""
        "", ""
      ]  

      @class[@step - 1] = "--active"  
      

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

      isVisible: !AlumNet.current_user.isExternal()    


  class Shared.Layout extends Marionette.LayoutView
    template: 'registration/shared/templates/layout'
    id: ''
    className: 'container-fluid'
    regions:
      side_region: '#sidebar-region' 
      form_region: '#form-region'


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