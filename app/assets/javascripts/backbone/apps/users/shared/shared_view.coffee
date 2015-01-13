@AlumNet.module 'UsersApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'users/shared/templates/header'    


  class Shared.Layout extends Marionette.LayoutView
    template: 'users/shared/templates/layout'
    

    regions:
      header: '#user-header'
      body: '#user-body'

  API =
    getUserLayout: (model)->
      new Shared.Layout
        model: model

    getUserHeader: (model)->
      new Shared.Header
        model: model

  AlumNet.reqres.setHandler 'user:layout', (model) ->
    API.getUserLayout(model)

  AlumNet.reqres.setHandler 'user:header', (model)->
    API.getUserHeader(model)