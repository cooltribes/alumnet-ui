@AlumNet.module 'BusinessExchangeApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Home.Layout extends Marionette.LayoutView
    template: 'admin/dashboard/users/templates/layout'

    ui:
      start_date: ".js-start-date"
      end_date: ".js-end-date"
      submit: ".js-submit"

    events:
      'click @ui.submit' : 'sendDates'

    regions:
      chart_type_1: '.chart_type_1'
      chart_type_2: '.chart_type_2'
