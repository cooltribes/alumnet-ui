@AlumNet.module 'UsersApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'users/shared/templates/header'  

    templateHelpers: ->                  
      model = @model
      position: ->
        model.profile.get("last_experience") ? "No Position"


  class Shared.Layout extends Marionette.LayoutView
    template: 'users/shared/templates/layout'

    regions:
      header: '#user-header'
      body: '#user-body'

    initialize: (options) ->      
      @tab = options.tab      
      @class = [
        "", "", ""
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

    getUserHeader: (model)->
      new Shared.Header
        model: model
        

  AlumNet.reqres.setHandler 'user:layout', (model, tab) ->
    API.getUserLayout(model, tab)

  AlumNet.reqres.setHandler 'user:header', (model)->
    API.getUserHeader(model)