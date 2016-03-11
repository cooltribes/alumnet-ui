@AlumNet.module 'BusinessExchangeApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  class Home.Tasks extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Task

  class Home.Profiles extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Profile

