@AlumNet.module 'BusinessExchangeApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Home.Layout extends Marionette.LayoutView
    template: 'business_exchange/home/templates/home_layout'

    # ui:
    #   start_date: ".js-start-date"
    #   end_date: ".js-end-date"
    #   submit: ".js-submit"

    # events:
    #   'click @ui.submit' : 'sendDates'

    regions:
      profiles: '.profiles-region'
      tasks: '.tasks-region'

    # templateHelpers: ->

  class Home.Tasks extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Task

  class Home.Profiles extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Profile
