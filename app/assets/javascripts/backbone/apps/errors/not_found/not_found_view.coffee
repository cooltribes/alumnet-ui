@AlumNet.module 'ErrorsApp.NotFound', (NotFound, @AlumNet, Backbone, Marionette, $, _) ->

  class NotFound.View extends Marionette.ItemView
    template: 'errors/not_found/templates/not_found'
