@AlumNet.module 'BusinessExchangeApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Home.Layout extends Marionette.LayoutView
    template: 'business_exchange/home/templates/home_layout'

    regions:
      profiles: '.profiles-region'
      tasks: '.tasks-region'

  class Home.Tasks extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Task

  class Home.Profiles extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Profile

