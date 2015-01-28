@AlumNet.module 'FriendsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  # class Shared.Header extends Marionette.ItemView
  #   template: 'friends/shared/templates/header'  


  class Shared.Layout extends Marionette.LayoutView
    template: 'friends/shared/templates/layout'

    regions:
      # header: '#user-header'
      body: '.friends-list'

    initialize: (options) ->      
      @tab = options.tab      
      @class = [
        "", "", ""
        "", ""
      ]  
      @class[parseInt(@tab)] = "--active"            
    

    templateHelpers: ->
      model = @model
      classOf: (step) =>
        @class[step]  
      
      friends: () ->
        model.fc

  API =
    getFriendsLayout: (model, tab)->
      new Shared.Layout
        model: model
        tab: tab

    # getUserHeader: (model)->
    #   new Shared.Header
    #     model: model
        

  AlumNet.reqres.setHandler 'my:friends:layout', (model, tab) ->
    API.getFriendsLayout(model, tab)

  # AlumNet.reqres.setHandler 'user:header', (model)->
  #   API.getUserHeader(model)