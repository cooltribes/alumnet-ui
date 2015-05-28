@AlumNet.module 'UsersApp.Business', (Business, @AlumNet, Backbone, Marionette, $, _) ->

  class Business.LayoutView extends Marionette.LayoutView
    template: 'users/about/templates/business'

    